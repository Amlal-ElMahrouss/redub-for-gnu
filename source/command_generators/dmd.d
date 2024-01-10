module command_generators.dmd;
import buildapi;
import command_generators.commons;

string[] parseBuildConfiguration(immutable BuildConfiguration b, OS target)
{
    import std.path:buildNormalizedPath;
    import std.array:array;
    import std.algorithm.iteration:map;
    
    string[] commands;
    with(b)
    {
        if(isDebug) commands~= "-debug";
        commands~= versions.map!((v) => "-version="~v).array;
        commands~= importDirectories.map!((i) => "-I"~i).array;

        if(targetType == TargetType.executable)
        {
            commands~= "-c"; //Compile only
            commands~= libraryPaths.map!((lp) => "-L-L"~lp).array;
            commands~= libraries.map!((l) => "-L-l"~l).array;
        }
        commands~= stringImportPaths.map!((sip) => "-J="~sip).array;

        string outFlag = getTargetTypeFlag(targetType);
        if(outFlag) commands~= outFlag;

        if(outputDirectory)
            commands~= "-od"~outputDirectory;
        if(targetType != TargetType.executable)
            commands~= "-of"~buildNormalizedPath(outputDirectory, getOutputName(targetType, name, os));
        else
            commands~= "-of"~buildNormalizedPath(outputDirectory, name~getObjectExtension(os));

        foreach(path; sourcePaths)
            commands~= getSourceFiles(buildNormalizedPath(workingDir, path));
    }

    return commands;
}

string[] parseLinkConfiguration(immutable BuildConfiguration b, OS target)
{
    import std.algorithm.iteration;
    import std.path;
    import std.array;
    string[] commands;
    with(b)
    {
        commands~= libraryPaths.map!((lp) => "-L-L"~lp).array;
        commands~= libraries.map!((l) => "-L-l"~l).array;
        commands~= buildNormalizedPath(outputDirectory, name~getObjectExtension(target));
        commands~= "-of"~buildNormalizedPath(outputDirectory, getOutputName(targetType, name, os));
    }
    return commands;
}

private string getTargetTypeFlag(TargetType o)
{
    final switch(o)
    {
        case TargetType.autodetect: return null;
        case TargetType.executable: return null;
        case TargetType.library, TargetType.staticLibrary: return "-lib";
        case TargetType.sharedLibrary: return "-shared";
    }
}