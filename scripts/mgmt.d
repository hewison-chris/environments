#!/usr/bin/env dub
/+
 dub.json:
{
    "name": "Management"
}
+/
/*******************************************************************************

     CLI tool to manage the servers

*******************************************************************************/
module mgmt;

import std.algorithm;
import std.array;
import std.process;
import std.stdio;
import std.uni : toLower;

immutable string[] Hosts = [
    "eu-002.bosagora.io",
    "na-001.bosagora.io",
    "na-002.bosagora.io",
];

enum Application
{
    Agora = (1 << 0),
    Stoa  = (1 << 1),
    All = Agora  | Stoa,
}

int showUsage ()
{
    stderr.writeln("USAGE: ./mgmt.d <COMMAND> <APP...> [<TARGET...>]");
    stderr.writeln();
    stderr.writeln("Commands are:");
    stderr.writeln("\t- status  : Print `systemctl status` of all instances");
    stderr.writeln("\t- restart : Restart (in systemctl parlance) the targets");
    stderr.writeln("\t- clear   : Clear storage of the targets");
    stderr.writeln("\t- update  : Fetch the new image(s) on targets then restart");
    stderr.writeln("\t- reset   : Update targets, clear storage, then restart");
    stderr.writeln();
    stderr.writeln("App is one of: all, agora, stoa");
    stderr.writeln("Target is one of: all, eu, na, eu-002, na-00{1,2}, or hostname");
    stderr.writeln();
    stderr.writeln("Target and apps are additive.");
    return 1;
}

int main (string[] args)
{
    if (args.length < 3)
    {
        if (args.length < 2)
            stderr.writeln("Missing first position parameter: <COMMAND>");
        else
            stderr.writeln("Missing second position parameter: <APP>");
        return showUsage();
    }

    Application app;
    switch (args[2].toLower)
    {
    case "all":
        app = Application.All;
        break;
    case "agora":
        app = Application.Agora;
        break;
    case "stoa":
        app = Application.Stoa;
        break;
    default:
        stderr.writeln("No such application: ", args[2]);
        stderr.writeln("Use one of: 'all', 'agora', 'stoa'");
        return 1;
    }

    const hosts = args.length >= 4 ? getHostList(args[3 .. $]) : Hosts;
    if (!hosts.length)
        return 1; // Error printed in getHostList

    switch (args[1].toLower)
    {
    case "status":
        return statusCommand(app, hosts);
    case "clear":
        return clearCommand(app, hosts);
    case "restart":
        return restartCommand(app, hosts);
    case "update":
        return updateCommand(app, hosts);
    case "reset":
        return resetCommand(app, hosts);
    default:
        stderr.writeln("Error: Unrecognized command '", args[1], "'");
        return showUsage();
    }
}

int statusCommand (Application app, in string[] hosts)
{
    alias TRet = typeof(execute([""]));
    static void onResult (string host, in TRet pid)
    {
        if (pid.status)
            stderr.writeln("Status for host ", host, " failed: ", pid.output);
        else
            stdout.writeln(pid.output);
    }

    foreach (h; hosts)
    {
        stdout.writeln("====================", h, "====================");
        final switch (app)
        {
        case Application.All, Application.Agora:
            auto pid = execute([ "ssh", h, "sudo systemctl status 'agora@*'" ]);
            onResult(h, pid);
            if (app == Application.All)
                goto case;
            break;
        case Application.Stoa:
            auto pid = execute([ "ssh", h, "sudo systemctl status stoa" ]);
            onResult(h, pid);
            break;
        }
    }
    return 0;
}

int clearCommand (Application app, in string[] hosts...)
{
    foreach (h; hosts)
    {
        stdout.writeln("Clearing cache in ", app, " instances on host: ", h);
        final switch (app)
        {
        case Application.Agora, Application.All:
            auto pid = execute([ "ssh", h, "sudo rm -rv /srv/agora/*/.cache/" ]);
            if (pid.status)
                stderr.writeln("Clearing cache on host ", h, " failed: ", pid.output);
            if (app == Application.All)
                goto case;
            break;

        case Application.Stoa:
            // Nothing to do
            break;
        }
    }
    return 0;
}

int restartCommand (Application app, in string[] hosts...)
{
    foreach (h; hosts)
    {
        stdout.writeln("Restarting ", app, " instances on host: ", h);
        final switch (app)
        {
        case Application.Agora, Application.All:
            auto pid = execute([ "ssh", h, "sudo systemctl restart 'agora@*'" ]);
            if (pid.status)
                stderr.writeln("Restarting Agora instances on ", h, "failed: ", pid.output);
            if (app == Application.All)
                goto case;
            break;

        case Application.Stoa:
            auto pid = execute([ "ssh", h, "sudo systemctl restart stoa" ]);
            if (pid.status)
                stderr.writeln("Restarting Stoa instances on ", h, "failed: ", pid.output);
        }
    }
    return 0;
}

bool updateHosts (Application app, in string[] hosts...)
{
    foreach (h; hosts)
    {
        stdout.writeln("Updating ", app, " instances on host: ", h);
        final switch (app)
        {
        case Application.Agora, Application.All:
            auto pid = execute([ "ssh", h, "sudo docker pull bpfk/agora" ]);
            if (pid.status)
                stderr.writeln("Updating Agora image on ", h, "failed: ", pid.output);
            if (app == Application.All)
                goto case;
            break;

        case Application.Stoa:
            auto pid = execute([ "ssh", h, "sudo docker pull bpfk/stoa" ]);
            if (pid.status)
                stderr.writeln("Updating Stoa image on ", h, "failed: ", pid.output);
        }
    }
    return true;
}

int updateCommand (Application app, in string[] hosts...)
{
    updateHosts(app, hosts);
    restartCommand(app, hosts);

    return 0;
}

int resetCommand (Application app, in string[] hosts)
{
    foreach (h; hosts)
    {
        stdout.writeln("Hard resetting ", app, " instances on host: ", h);
        updateHosts(app, h);
        clearCommand(app, h);
    }
    return 0;
}

const(string)[] getHostList(string[] args)
{
    string[] results;
    if (!args.length)
    {
        stderr.writeln("Error: Missing target(s) argument");
        showUsage();
        return null;
    }

    foreach (arg; args)
    {
    SW: switch (arg.toLower)
        {
        case "all":
            return Hosts;
        case "eu", "eu-002":
            results ~= Hosts[0];
            break;
        case "na":
            results ~= Hosts[1 .. $];
            break;
        case "na-001":
            results ~= Hosts[1];
            break;
        case "na-002":
            results ~= Hosts[2];
            break;

        static foreach (H; Hosts)
        {
        case H:
            results ~= H;
            break SW;
        }

        default:
            stderr.writeln("Unrecognized host ", arg);
            return null;
        }
    }
    return results.sort.uniq.array;
}
