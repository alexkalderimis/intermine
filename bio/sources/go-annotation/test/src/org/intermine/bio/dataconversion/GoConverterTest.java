package org.intermine.bio.dataconversion;

/*
 * Copyright (C) 2002-2007 FlyMine
 *
 * This code may be freely distributed and modified under the
 * terms of the GNU Lesser General Public Licence.  This should
 * be distributed with the code.  See the LICENSE file for more
 * information or http://www.gnu.org/copyleft/lesser.html.
 *
 */

import java.io.File;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Set;

import org.intermine.dataconversion.ItemsTestCase;
import org.intermine.dataconversion.MockItemWriter;
import org.intermine.metadata.Model;
import org.intermine.xml.full.Item;
import org.intermine.xml.full.ItemFactory;


public class GoConverterTest extends ItemsTestCase
{
    private File goFile;
    private File goOboFile;

    protected static final String GENOMIC_NS = "http://www.flymine.org/model/genomic#";

    public GoConverterTest(String arg) {
        super(arg);
    }

    public void setUp() throws Exception {
//        goFile = File.createTempFile("go-tiny", ".ontology");
//      
//        Reader goReader = new InputStreamReader(
//                getClass().getClassLoader().getResourceAsStream("go-tiny.ontology"));
//        writeTempFile(goFile, goReader);

      goOboFile = File.createTempFile("gene_ontology", ".obo");
      Reader goOboReader = new InputStreamReader(
              getClass().getClassLoader().getResourceAsStream("gene_ontology.obo"));
        
//        goOboFile = File.createTempFile("go-tiny", ".obo");
//        Reader goOboReader = new InputStreamReader(
//                getClass().getClassLoader().getResourceAsStream("go-tiny.obo"));
        writeTempFile(goOboFile, goOboReader);
    }

    private void writeTempFile(File outFile, Reader srcFileReader) throws Exception{
        FileWriter fileWriter = new FileWriter(outFile);
        int c;
        while ((c = srcFileReader.read()) > 0) {
            fileWriter.write(c);
        }
        fileWriter.close();
    }

    public void tearDown() throws Exception {
        //goFile.delete();
        //goOboFile.delete();
    }

//    public void testTranslate() throws Exception {
//        translateCommon(goFile, "GoConverterTest_src.txt",
//                "GoConverterTest_tgt.xml", true, false);
//    }

    public void testOboTranslate() throws Exception {
        translateCommon(goOboFile, "GoConverterOboTest_src.txt",
                "GoConverterOboTest_tgt.xml", true, false);
    }

    private void translateCommon(File onotologyFile, String srcFile, String tgtFile,
                                 boolean verbose, boolean writeItemFile) throws Exception{

        Reader reader = new InputStreamReader(
                getClass().getClassLoader().getResourceAsStream(srcFile));
        MockItemWriter writer = new MockItemWriter(new LinkedHashMap());
        GoConverter converter = new GoConverter(writer);
        converter.setOntologyfile(onotologyFile);
        converter.process(reader);
        converter.close();

        // uncomment to write a new target items file
        //writeItemsFile(writer.getItems(), "go-tgt-items.xml");
        
        assertEquals(readItemSet(tgtFile), writer.getItems());
    }


    public void testCreateWithObjects() throws Exception {
        MockItemWriter writer = new MockItemWriter(new LinkedHashMap());
        GoConverter converter = new GoConverter(writer);

        Set expected = new HashSet();
        ItemFactory tgtItemFactory = new ItemFactory(Model.getInstanceByName("genomic"));
        Item gene1 = tgtItemFactory.makeItem("2_2", GENOMIC_NS + "Gene", "");
        gene1.setAttribute("organismDbId", "FBgn0026430");
        gene1.addToCollection("evidence", "0_3");
        expected.add(gene1);
        Item gene2 = tgtItemFactory.makeItem("2_5", GENOMIC_NS + "Gene", "");
        gene2.setAttribute("organismDbId", "FBgn0001612");
        gene2.addToCollection("evidence", "0_3");
        expected.add(gene2);
        Item organism = tgtItemFactory.makeItem("1_1", GENOMIC_NS + "Organism", "");
        organism.setAttribute("taxonId", "7227");
        assertEquals(expected, converter.createWithObjects(
                "FLYBASE:Grip84; FB:FBgn0026430, FLYBASE:l(1)dd4; FB:FBgn0001612", organism, "10_10"));
    }
}
