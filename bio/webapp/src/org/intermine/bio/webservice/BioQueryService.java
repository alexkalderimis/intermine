package org.intermine.bio.webservice;

/*
 * Copyright (C) 2002-2014 FlyMine
 *
 * This code may be freely distributed and modified under the
 * terms of the GNU Lesser General Public Licence.  This should
 * be distributed with the code.  See the LICENSE file for more
 * information or http://www.gnu.org/copyleft/lesser.html.
 *
 */

import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import org.apache.log4j.Logger;
import org.intermine.api.InterMineAPI;
import org.intermine.api.profile.Profile;
import org.intermine.api.query.PathQueryExecutor;
import org.intermine.api.results.ExportResultsIterator;
import org.intermine.metadata.ClassDescriptor;
import org.intermine.objectstore.ObjectStoreException;
import org.intermine.pathquery.Constraints;
import org.intermine.pathquery.Path;
import org.intermine.pathquery.PathConstraint;
import org.intermine.pathquery.PathException;
import org.intermine.pathquery.PathQuery;
import org.intermine.metadata.StringUtil;
import org.intermine.web.logic.export.Exporter;
import org.intermine.web.logic.export.ResponseUtil;
import org.intermine.webservice.server.Format;
import org.intermine.webservice.server.WebServiceRequestParser;
import org.intermine.webservice.server.exceptions.BadRequestException;
import org.intermine.webservice.server.exceptions.ServiceException;
import org.intermine.webservice.server.output.Output;
import org.intermine.webservice.server.output.PlainFormatter;
import org.intermine.webservice.server.output.StreamedOutput;
import org.intermine.webservice.server.query.AbstractQueryService;
import org.intermine.webservice.server.query.result.PathQueryBuilder;

/**
 * A service for exporting query results as gff3.
 * @author Alexis Kalderimis.
 *
 */
public abstract class BioQueryService extends AbstractQueryService
{
    @SuppressWarnings("unused")
    private static final Logger LOG = Logger.getLogger(BioQueryService.class);

    private static final String XML_PARAM = "query";
    private static final String VIEW_PARAM = "view";

    private PrintWriter pw;

    public PrintWriter getPrintWriter() {
        return pw;
    }

    private OutputStream os;

    public OutputStream getOutputStream() {
        return os;
    }

    /**
     * Constructor.
     * @param im A reference to an InterMine API settings bundle.
     */
    public BioQueryService(InterMineAPI im) {
        super(im);
    }

    @Override
    protected String getDefaultFileName() {
        return "results" + StringUtil.uniqueString() + getSuffix();
    }

    protected abstract String getSuffix();

    protected abstract String getContentType();

    @Override
    protected Output getDefaultOutput(PrintWriter out, OutputStream os, String sep) {
        // Most exporters need direct access to these.
        this.os = os;
        this.pw = out;
        output = new StreamedOutput(out, new PlainFormatter(), sep);
        if (isUncompressed()) {
            ResponseUtil.setCustomTypeHeader(response, getDefaultFileName(), getContentType());
        }
        return output;
    }

    @Override
    public Format getDefaultFormat() {
        return Format.UNKNOWN;
    }


    /**
     * Return the query specified in the request, shorn of all duplicate
     * classes in the view. Note, it is the users responsibility to ensure
     * that there are only SequenceFeatures in the view.
     *
     * @return A query.
     */
    protected PathQuery getQuery() {
        String xml = getRequiredParameter(XML_PARAM);
        PathQueryBuilder builder = getQueryBuilder(xml);
        PathQuery pq = builder.getQuery();

        List<String> newView = new ArrayList<String>();
        Set<ClassDescriptor> seenTypes = new HashSet<ClassDescriptor>();

        for (String viewPath: pq.getView()) {
            Path p;
            try {
                p = new Path(pq.getModel(), viewPath);
            } catch (PathException e) {
                throw new BadRequestException("Query is invalid", e);
            }
            ClassDescriptor cd = p.getLastClassDescriptor();
            if (!seenTypes.contains(cd)) {
                newView.add(viewPath);
            }
            seenTypes.add(cd);
        }
        if (!newView.equals(pq.getView())) {
            pq.clearView();
            pq.addViews(newView);
        }

        // Replace the view, if required.
        Collection<String> views = getPathQueryViews(request.getParameterValues(VIEW_PARAM));
        if (views != null && !views.isEmpty()) {
            Collection<String> oldViews = pq.getView();
            pq.clearView();
            for (String viewPath: views) {
                try { // Handle one at a time so we can throw errors at the offending path.
                    pq.addView(viewPath);
                } catch (IllegalArgumentException e) {
                    throw new BadRequestException("Bad view path: " + viewPath);
                }
            }
            // Ensure that we haven't changed the query by changing the view.
            for (String oldView: oldViews) {
                try {
                    ensurePathIsRelevantToQuery(pq, oldView);
                } catch (PathException e) {
                    throw new BadRequestException("Illegal path: " + oldView);
                }
            }
        }
        // Allow sub-classes to check for validity.
        checkPathQuery(pq);

        return pq;
    }

    protected abstract Exporter getExporter(PathQuery pq);

    protected void checkPathQuery(PathQuery pq) throws ServiceException {
        // No-op stub. Put query validation here.
    }

    @Override
    protected void execute() throws ServiceException {

        // Values defined by context.
        Profile profile = getPermission().getProfile();
        PathQueryExecutor executor = this.im.getPathQueryExecutor(profile);

        // Values defined by parameters.
        PathQuery pathQuery = getQuery();
        int start = getIntParameter("start", 0);
        int size = getIntParameter("size", WebServiceRequestParser.DEFAULT_MAX_COUNT);

        Exporter exporter = getExporter(pathQuery);

        ExportResultsIterator iter = null;
        try {
            iter = executor.execute(pathQuery, start, size);
            iter.goFaster();
            exporter.export(iter);
        } catch (ObjectStoreException e) {
            throw new ServiceException("Error running query.", e);
        } finally {
            if (iter != null) {
                iter.releaseGoFaster();
            }
        }
    }

    private void ensurePathIsRelevantToQuery(PathQuery pathQuery, String pathString) throws PathException {
        Path path = pathQuery.makePath(pathString);
        Path parent = path.getPrefix();
        for (String viewPathString: pathQuery.getView()) {
            Path viewPath = pathQuery.makePath(viewPathString);
            Path viewNode = viewPath.getPrefix();
            if (parent.equals(viewNode)) {
                return; // Already relevant.
            }
        }
        // Not in the view. Check the constraints.
        for (PathConstraint con: pathQuery.getConstraints().keySet()) {
            Path node = pathQuery.makePath(con.getPath());
            if (node.equals(parent)) {
                return; // Already relevant.
            }
        }
        // Not in view, nor in constraints. Add it back as a NOT NULL constraint.
        pathQuery.addConstraint(Constraints.isNotNull(pathString));
    }

    /**
     * Parse path query views from the "view" request parameter.
     *
     * Returns the empty set if no input is provided.
     *
     * @param The viewpaths given as request parameters.
     * @return a list of paths as strings. Never null.
     */
    protected static Collection<String> getPathQueryViews(String[] views) {
        if (views == null || views.length < 1) {
            return Collections.emptySet();
        }

        Collection<String> cleaned = new LinkedHashSet<String>();
        for (String view : views) {
            cleaned.add(view.trim());
        }

        return cleaned;
    }

    /**
     * Parse view strings to Path objects
     *
     * @param views
     * @return a list of query path
     */
    protected List<Path> getQueryPaths(PathQuery pq) {
        List<Path> paths = new ArrayList<Path>();
        for (String view : pq.getView()) {
            try {
                paths.add(pq.makePath(view));
            } catch (PathException e) {
                e.printStackTrace();
            }
        }
        return paths;
    }
}
