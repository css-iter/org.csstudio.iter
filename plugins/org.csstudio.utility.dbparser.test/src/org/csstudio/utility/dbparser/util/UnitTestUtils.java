/*******************************************************************************
 * Copyright (c) 2010-2019 ITER Organization.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 ******************************************************************************/
package org.csstudio.utility.dbparser.util;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import org.eclipse.core.resources.IFile;

/**
 * Helper for unit tests.
 *
 * @author Fred Arnaud (Sopra Group) - ITER
 */
public class UnitTestUtils {

    public static File getTestResource(String name) throws FileNotFoundException {
        return new File("resources/test/" + name);
    }

    public static IFile getTestIResource(String name) throws FileNotFoundException {
        return new MockIFile(getTestResource(name));
    }

    public static String readFile(File file) throws IOException {
        StringBuilder out = new StringBuilder();
        BufferedReader br = new BufferedReader(new FileReader(file));
        for (String line = br.readLine(); line != null; line = br.readLine())
            out.append(line + "\n");
        br.close();
        return out.toString();
    }

    public static void writeFile(String filename, String content) throws IOException {
        BufferedWriter writer = new BufferedWriter(new FileWriter(filename));
        writer.write(content);
        writer.close();
    }
}
