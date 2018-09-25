ITER-CODAC's JFace
==================

This is a fork of the official org.eclipse.jface plugin from the Eclipse 4.7 Oxygen release.

The raison d'être of this fork is to fix issues related with double size icons described in the following tickets:

+ https://bugzilla.iter.org/codac/show_bug.cgi?id=7063
+ https://bugzilla.iter.org/codac/show_bug.cgi?id=11062

The baseline source code is taken from branch R4_7_maintenance of Eclipse Platform UI project (https://github.com/eclipse/eclipse.platform.ui/tree/R4_7_maintenance/bundles/org.eclipse.jface).

The changes applied to the source code are the following:

+ Setup standard configuration files to integrate this bundle into ITER-CODAC build.
+ Patch src/org/eclipse/jface/resource/URLImageDescriptor.java to use org.eclipse.jface/forceIconZoomLevel parameter when selecting the icon size, overriding the standard zoom settings. For instance, setting forceIconZoomLevel to 200 will force to load icons following the @2x convention, if they exist.

*Note: This fork was already done for Eclipse 4.6 Neon. In order to upgrade it to Eclipse 4.7 Oxygen, all files from Eclise 4.6 have been replaced by Eclipse 4.7 ones, and then the patch has been reapplied to the upgraded files.*
