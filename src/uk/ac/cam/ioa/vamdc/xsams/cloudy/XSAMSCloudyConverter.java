package uk.ac.cam.ioa.vamdc.xsams.cloudy;

import java.io.File;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;

public class XSAMSCloudyConverter {

	private String[] xsamsFileList;

	String xsamsDirectory;

	@SuppressWarnings("unchecked")
	public static void main(String[] args) {

		//System.out.println(args.length);
		
		XSAMSCloudyConverter client = new XSAMSCloudyConverter();

		client.xsamsDirectory = "/opt/XSAMS";
		if(args.length == 0){
			System.out.println("Please, pass directory with XSAMS files to process");
			//System.exit(0);
		} else {
			System.out.println(args[0]);
			client.xsamsDirectory = args[0];
		}
		
		if (client.directoryEmpty(client.xsamsDirectory)) {
			boolean success = (new File(client.xsamsDirectory + "/output"))
					.mkdir();
			if (!success) {
				// Directory creation failed
			}
			// Freemarker configuration object
			Configuration cfg = new Configuration();
			try {
				// Load template from source folder
				Template template = cfg.getTemplate("src/xsams.ftl");

				// Build the data-model
				Map root = new HashMap();

				// spectra-Ar.xml
				// spectra-Ag.xml
				// spectra-Ti.xml
				// vald-Ag.xml
				// vald-Ar.xml
				// vald-Ti.xml
				// chianti-Ar.xml
				// topbase-Ar.xml

				for (int i = 0; i < client.xsamsFileList.length; i++) {
					System.out.println("Processing: " + client.xsamsFileList[i]);
					root.put("doc", freemarker.ext.dom.NodeModel
							.parse(new File(client.xsamsDirectory + "/"
									+ client.xsamsFileList[i])));

					// Console output Writer out = new
					// OutputStreamWriter(System.out); template.process(root,
					// out);
					// out.flush();

					int index = client.xsamsFileList[i].lastIndexOf('.');
					if (index > 0
							&& index <= client.xsamsFileList[i].length() - 2) {
						String outputFile = client.xsamsFileList[i].substring(
								0, index);
				
						// File output
						Writer file = new FileWriter(new File(
								client.xsamsDirectory + "/output/" + outputFile
										+ ".output"));
						template.process(root, file);
						file.flush();
						file.close();
					}
				}

			} catch (IOException e) {
				e.printStackTrace();
			} catch (TemplateException e) {
				e.printStackTrace();
			} catch (SAXException e) { 
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (ParserConfigurationException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
	}

	private boolean directoryCheck(String directoryPath) {
		boolean exists = (new File(directoryPath)).exists();
		if (exists) {
			return true;
		} else {
			return false;
		}
	}

	private boolean directoryEmpty(String directoryPath) {
		if (directoryCheck(directoryPath)) {
			File dir = new File(directoryPath);
			if (dir.isDirectory()) {
				if (dir.list().length > 0) {
					FilenameFilter filter = new FilenameFilter() {
						public boolean accept(File dir, String name) {
							return name.endsWith(".xml")
									|| name.endsWith(".xsams");
							// return !name.startsWith(".");
						}
					};
					xsamsFileList = dir.list(filter);
					for (int i = 0; i < xsamsFileList.length; i++) {
						// xsamsFileList = new String[children.length];
						// xsamsFileList[i] = directoryPath + "/" + children[i];
						System.out.println(xsamsFileList[i]);
					}
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
}
