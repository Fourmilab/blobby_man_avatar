    /*

                       Fourmilab Blobby Man

                     by John Walker (Fourmilab)

        This script provides control over the appearance of the components
        which make up the Blobby Man wearable avatar.  The script is included
        in every component of the scripted edition of the avatar.  You can
        either send commands to all components via the command channel, or
        select components by beginning the command with a list of their
        name(s), for example:

            /1987 Left Foot, Nose: colour <1, 0, 0>

        After configuring the components as you wish, you can delete the
        scripts in all components to prevent further changes and avoid
        overload on the simulator (which, insanely, wastes time on scripts
        which are simply waiting for input) with the "Kill scripts"
        command.

    */

    string version = "2020-11-25T14:01Z";

    key owner;                      // Owner / wearer key
    integer commandChannel = 1987;  // Command channel in chat (Blobby Man publication year)
    integer commandH = 0;           // Handle for command channel
    key whoDat = NULL_KEY;          // Avatar who sent command
    integer primary = FALSE;        // Are we the primary component (with script processor) ?

    string confNotecard = "Blobby Man Configuration";  // Configuration notecard
    string helpFileName = "Fourmilab Blobby Man Avatar User Guide"; // Help file
    string scriptPro = "Script Processor";  // Script processor script name

    integer echo = TRUE;            // Echo commands ?
    integer trace = FALSE;          // Trace operation ?

    vector colourStd = <0.788, 0.58, 0.455>;    // Standard colour
    integer HSV = FALSE;            // Choose colour in the HSV colour space ?
    vector colourMin = < 0, 0, 0 >; // Colour minimum in selected space
    vector colourMax = < 1, 1, 1 >; // Colour maximum in selected space

    integer poly = FALSE;           // Polychrome colour morphing ?
    vector polyLast;                // Polychrome last colour
    vector polyNext;                // Polychrome next colour
    float polyTickLength = 0.25;    // Time between ticks, seconds
    float polyChangeTime = 25;      // Time between new colour target selection, seconds
    integer polyTicks;              // Tick counter
    integer polyChangeTicks;        // Choose new colour after ticks

    integer bcChannel = -982449802; // Broadcast channel
    integer broadcast = FALSE;      // Broadcast colour changes ?
    integer bcreceive = FALSE;      // Receive broadcast changes ?
    integer broadcastH = 0;         // Handle for listening to broadcasts

    //  Script processing

    integer scriptActive = FALSE;   // Are we reading from a script ?
    integer scriptSuspend = FALSE;  // Suspend script execution for asynchronous event
    integer configuring = FALSE;    // Reading configuration script ?
    integer fwdwaited = FALSE;      // Done waiting before forwarding configuration ?

    //  Script Processor messages

    integer LM_SP_INIT = 50;        // Initialise
//  integer LM_SP_RESET = 51;       // Reset script
//  integer LM_SP_STAT = 52;        // Print status
    integer LM_SP_RUN = 53;         // Enqueue script as input source
    integer LM_SP_GET = 54;         // Request next line from script
    integer LM_SP_INPUT = 55;       // Input line from script
    integer LM_SP_EOF = 56;         // Script input at end of file
    integer LM_SP_READY = 57;       // Script ready to read
    integer LM_SP_ERROR = 58;       // Requested operation failed

    //  Command processor messages

    integer LM_CP_COMMAND = 223;    // Process command

    //  tawk  --  Send a message to the interacting user in chat

    tawk(string msg) {
        if (whoDat == NULL_KEY) {
            //  No known sender.  Say in nearby chat.
            llSay(PUBLIC_CHANNEL, msg);
        } else {
            /*  While debugging, when speaking to the owner, use llOwnerSay()
                rather than llRegionSayTo() to avoid the risk of a runaway
                blithering loop triggering the gag which can only be removed
                by a region restart.  */
            if (owner == whoDat) {
                llOwnerSay(msg);
            } else {
                llRegionSayTo(whoDat, PUBLIC_CHANNEL, msg);
            }
        }
    }

    /*  hsv_to_rgb  --  Convert HSV colour values stored in a vector
                        (H = x, S = y, V = z) to RGB (R = x, G = y, B = z).
                        The Hue is specified as a number from 0 to 1
                        representing the colour wheel angle from 0 to 360
                        degrees, while saturation and value are given as
                        numbers from 0 to 1.  */

    vector hsv_to_rgb(vector hsv) {
        float h = hsv.x;
        float s = hsv.y;
        float v = hsv.z;

        if (s == 0) {
            return < v, v, v >;             // Grey scale
        }

        if (h >= 1) {
            h = 0;
        }
        h *= 6;
        integer i = (integer) llFloor(h);
        float f = h - i;
        float p = v * (1 - s);
        float q = v * (1 - (s * f));
        float t = v * (1 - (s * (1 - f)));
        if (i == 0) {
            return < v, t, p >;
        } else if (i == 1) {
            return < q, v, p >;
        } else if (i == 2) {
            return <p, v, t >;
        } else if (i == 3) {
            return < p, q, v >;
        } else if (i == 4) {
            return < t, p, v >;
        } else if (i == 5) {
            return < v, p, q >;
        }
llOwnerSay("Blooie!  " + (string) hsv);
        return < 0, 0, 0 >;
    }

    //  chooseColour  --  Choose the next target colour

    vector chooseColour() {
        vector crange = colourMax - colourMin;
        vector colour = colourMin +
                            < crange.x * llFrand(1),
                              crange.y * llFrand(1),
                              crange.z * llFrand(1) >;
        return colour;
    }

    //  Panic  --  Restore standard parameters and modes

    panic() {
        if (poly) {
            poly = FALSE;
            llSetTimerEvent(0);
        }
        polyTickLength = 0.25;
        polyChangeTime = 25;
        polyChangeTicks = (integer) llRound(polyChangeTime / polyTickLength);
        HSV = FALSE;
        colourMin = <0, 0, 0>;
        colourMax = <1, 1, 1>;
        llSetLinkPrimitiveParamsFast(LINK_THIS,
            [   PRIM_COLOR, ALL_SIDES, colourStd, 1,
                PRIM_GLOW, ALL_SIDES, 0,
                PRIM_POINT_LIGHT, FALSE, <1, 1, 1>, 0, 1, 1
            ]);
        broadcast = FALSE;
        bcreceive = FALSE;
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  onOff  --  Parse an on/off parameter

    integer onOff(string param) {
        if (abbrP(param, "on")) {
            return TRUE;
        } else if (abbrP(param, "of")) {
            return FALSE;
        } else {
            return -1;
        }
    }

    //  ef  --  Edit floats in string to parsimonious representation

    string efv(vector v) {
        return ef((string) v);
    }

    string eff(float f) {
        return ef((string) f);
    }

    //  Static constants to avoid costly allocation
    string efkdig = "0123456789";
    string efkdifdec = "0123456789.";

    string ef(string s) {
        integer p = llStringLength(s) - 1;

        while (p >= 0) {
            //  Ignore non-digits after numbers
            while ((p >= 0) &&
                   (llSubStringIndex(efkdig, llGetSubString(s, p, p)) < 0)) {
                p--;
            }
            //  Verify we have a sequence of digits and one decimal point
            integer o = p - 1;
            integer digits = 1;
            integer decimals = 0;
            string c;
            while ((o >= 0) &&
                   (llSubStringIndex(efkdifdec, (c = llGetSubString(s, o, o))) >= 0)) {
                o--;
                if (c == ".") {
                    decimals++;
                } else {
                    digits++;
                }
            }
            if ((digits > 1) && (decimals == 1)) {
                //  Elide trailing zeroes
                integer b = p;
                while ((b >= 0) && (llGetSubString(s, b, b) == "0")) {
                    b--;
                }
                //  If we've deleted all the way to the decimal point, remove it
                if ((b >= 0) && (llGetSubString(s, b, b) == ".")) {
                    b--;
                }
                //  Remove everything we've trimmed from the number
                if (b < p) {
                    s = llDeleteSubString(s, b + 1, p);
                    p = b;
                }
                //  Done with this number.  Skip to next non digit or decimal
                while ((p >= 0) &&
                       (llSubStringIndex(efkdifdec, llGetSubString(s, p, p)) >= 0)) {
                    p--;
                }
            } else {
                //  This is not a floating point number
                p = o;
            }
        }
        return s;
    }

    //  eFlou  --  Edit a value which may be 0, 1, or a fuzzy intermediate

    string eFlou(float v) {
        if (v == FALSE) {
            return "off";
        } else if (v == TRUE) {
            return "on";
        }
        return eff(v);
    }

    /*  fixArgs  --  Transform command arguments into canonical form.
                     All white space within vector and rotation brackets
                     is elided so they will be parsed as single arguments.  */

    string fixArgs(string cmd) {
        cmd = llStringTrim(cmd, STRING_TRIM);
        integer l = llStringLength(cmd);
        integer inbrack = FALSE;
        integer i;
        string fcmd = "";

        for (i = 0; i < l; i++) {
            string c = llGetSubString(cmd, i, i);
            if (inbrack && ((c == ">") || (c == "}"))) {
                inbrack = FALSE;
            }
            if ((c == "<") || (c == "{")) {
                inbrack = TRUE;
            }
            if (!((c == " ") && inbrack)) {
                fcmd += c;
            }
        }
        return fcmd;
    }

    //  configureComplete  --  Perform post-configuration processing

    configureComplete() {
        polyChangeTicks = (integer) llRound(polyChangeTime / polyTickLength);
        if (polyChangeTicks < 0) {
            polyChangeTicks = 1;
        }
        if (commandH == 0) {
            commandH = llListen(commandChannel, "", whoDat, "");
            if (primary) {
                tawk("Listening on /" + (string) commandChannel);
            }
        }
        if (broadcastH == 0) {
            broadcastH = llListen(bcChannel, "", "", "");
        }
    }

    //  processCommand  --  Process a command

    integer processCommand(key id, string message, integer fromScript) {
        if (id != owner) {
            llRegionSayTo(id, PUBLIC_CHANNEL,
                "You do not have permission to control this object.");
            return FALSE;
        }

        /*  If this command is directed to one or more components,
            see if it's for us.  Note that handling of commands from
            local chat and those from scripts is fundamentally
            different in that local chat commands are received
            directly by all components, who simply test whether
            they are named in the direction list.  Commands from
            scripts are read only by the primary component which
            must process them if it is included in the direction
            and then forward the command to other components who
            may be named in the direction.  */

        integer direction;
        if ((direction = llSubStringIndex(message, ": ")) >= 0) {
            integer forMe = (direction > 0) &&
                (llSubStringIndex(llGetSubString(message, 0, direction - 1),
                     llGetObjectName()) >= 0);
            /*  One further wrinkle.  If this was from a script,
                forward it so other attachments can process if
                directed to them.  You can send a command to all other
                attachments by preceding the command with ": " or
                "*: " to send the command to all other attachments and
                process it locally as well.  */
            if (fromScript) {
                string dss = llStringTrim(llGetSubString(message, 0, direction - 1),
                    STRING_TRIM);
                string fmessage = message;
                /*  If this is a ": " or "*: " forward, remove the wildcard
                    direction from the message before forwarding it to the
                    other components.  Otherwise, leave the direction in
                    place so they can determine whether it's for them.  */
                if ((direction == 0) || (dss == "*")) {
                    fmessage = llGetSubString(fmessage, direction + 2, -1);
                }
                if (trace) {
                    tawk("=> " + " \"" + message + "\"");
                }
                if (configuring && (!fwdwaited)) {
                    /*  This, boys and girls, is what we call a huge,
                        ugly sledgehammer.  When we're processing commands
                        from a configuration script, the odds are that
                        the user has just added all of the components of
                        the avatar from a folder.  It takes a while for
                        this to complete, and components can be added in
                        any order.  If we forward a command and one or more
                        of the components just attached hasn't yet started
                        listening on bcChannel, it will never see the command
                        and fail to initialise.  We could (and, indeed, should)
                        wait for all of the individual components to check in
                        with messages on bcChannel, but rather than introducing
                        all of that complexity, we just swing the Hammer of
                        Timer Sloppiness and introduce a delay before the first
                        forwarded command which should be sufficient to allow
                        all the other attachments to get up, running, and
                        listening.  */
                    llSleep(10);
                    fwdwaited = TRUE;
                }
                llRegionSayTo(owner, bcChannel, "COMMAND," + fmessage);
                if (!(forMe || (dss == "*"))) {
                    return TRUE;
                }
            } else {
                if (!forMe) {
                    return TRUE;
                }
            }
            message = llGetSubString(message, direction + 2, -1);
        }

        whoDat = id;            // Direct chat output to sender of command

        string prefix = ">> /" + (string) commandChannel + " ";
        if (fromScript) {
            prefix = "++ ";
        }
        if ((echo && primary) || trace) {
            tawk(prefix + message);                 // Echo command to sender
        }

        string lmessage = fixArgs(llToLower(message));
        list args = llParseString2List(lmessage, [ " " ], []);    // Command and arguments
        integer argn = llGetListLength(args);       // Number of arguments
        string command = llList2String(args, 0);    // The command
        string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Boot                        Reset the script

        if (abbrP(command, "bo")) {
            llResetScript();

        //  Clear                       Clear chat for debugging

        } else if (primary && abbrP(command, "cl")) {
            tawk("\n\n\n\n\n\n\n\n\n\n\n\n\n");

        //  Help                        Give User Guide notecard to requester

        } else if (abbrP(command, "he")) {
            if (llGetInventoryKey(helpFileName) != NULL_KEY) {
                llGiveInventory(id, helpFileName);
            }

        //  Kill script                 Delete this script after configuration

        } else if (abbrP(command, "ki")) {
            if (abbrP(sparam, "sc")) {
                if (primary) {
                    //  If we're primary, delete Script Processor as well
                    llRemoveInventory(scriptPro);
                }
                llRemoveInventory(llGetScriptName());
                while (TRUE) {
                    llSleep(0.1);       // Just waitin' for the reaper
                }
            }

        //  Panic [ gently ]            Restore standard properties and modes

        } else if (abbrP(command, "pa")) {
            panic();
            if ((argn < 2) || (!abbrP(sparam, "ge"))) {
                //  Terminate any running script
                llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);
            }

        //  Script                      Script commands (handled by Script Processor)

        } else if (abbrP(command, "sc")) {
            if (primary) {
                llMessageLinked(LINK_THIS, LM_CP_COMMAND,
                    llList2Json(JSON_ARRAY, [ message, lmessage ] + args), whoDat);
            }

        //  Set

        } else if (abbrP(command, "se")) {
            string svalue = llList2String(args, 2);
            string scvalue = llList2String(args, 3);
            string sdvalue = llList2String(args, 4);

            //  Set alpha n

            if (abbrP(sparam, "al")) {
                float alpha = onOff(svalue);
                if (alpha < 0) {
                    alpha = (float) svalue;
                }
                llSetAlpha(alpha, ALL_SIDES);

            //  Set Broadcast send/receive/channel n

            } else if (abbrP(sparam, "br")) {
                if (abbrP(svalue, "ch")) {          // Channel n
                    bcChannel = (integer) scvalue;
                    if (broadcastH != 0) {
                        llListenRemove(broadcastH);
                        broadcastH = llListen(bcChannel, "", "", "");
                    }
                } else if (abbrP(svalue, "re")) {   // Receive
                    bcreceive = onOff(scvalue);
                } else if (abbrP(svalue, "se")) {   // Send
                    broadcast = onOff(scvalue);
                } else {
                    tawk("Error: set broadcast send/receive/channel n");
                    return FALSE;
                }
                if (broadcast && bcreceive) {
                    tawk("Error: cannot broadcast send and receive at the same time.  Both disabled.");
                    broadcast = bcreceive = FALSE;
                    return FALSE;
                }

            //  Set channel n

            } else if (abbrP(sparam, "ch")) {
                integer newch = (integer) svalue;
                if ((newch < 2)) {
                    tawk("Invalid channel " + (string) newch + ".");
                    return FALSE;
                } else {
                    if (commandH != 0) {
                        llListenRemove(commandH);
                    }
                    commandChannel = newch;
                    commandH = llListen(commandChannel, "", whoDat, "");
                    tawk("Listening on /" + (string) commandChannel);
                }

            //  Set colour <r, g, b>/HSV/RGB/Simpsons/standard/random/poly/min/max

            } else if (abbrP(sparam, "co")) {
                vector cv;

                //  HSV
                if (abbrP(svalue, "hs")) {
                    HSV = TRUE;
                    return TRUE;
                //  Min <r, g, b> / <h, s, v>
                } else if (abbrP(svalue, "mi")) {
                    colourMin = (vector) scvalue;
                    return TRUE;
                //  Max <r, g, b> / <h, s, v>
                } else if (abbrP(svalue, "ma")) {
                    colourMax = (vector) scvalue;
                    return TRUE;
                //  Poly
                } else if (abbrP(svalue, "po")) {
                    poly = TRUE;
                    polyLast = polyNext = llGetColor(ALL_SIDES);
                    polyTicks = 0;
                    llSetTimerEvent(polyTickLength);
                    return TRUE;
                //  Random
                } else if (abbrP(svalue, "ra")) {
                    cv = chooseColour();
                    if (HSV) {
                        cv = hsv_to_rgb(cv);
                    }
                 //  RGB
                } else if (abbrP(svalue, "rg")) {
                    HSV = FALSE;
                    return TRUE;
                 //  Simpsons
                } else if (abbrP(svalue, "si")) {
                    cv = <1, 0.851, 0.059>;
                //  Standard
                } else if (abbrP(svalue, "st")) {
                    cv = colourStd;
                //  <r, g, b> / <h, s, v>
                } else {
                    cv = (vector) svalue;
                    if (HSV) {
                        cv = hsv_to_rgb(cv);
                    }
                }
                if (poly) {
                    poly = FALSE;
                    llSetTimerEvent(0);
                }
                llSetColor(cv, ALL_SIDES);

            //  Set echo on/off

            } else if (abbrP(sparam, "ec")) {
                echo = onOff(svalue);

            //  Set glow n/on/off

            } else if (abbrP(sparam, "gl")) {
                float glow = onOff(svalue);
                if (glow < 0) {
                    glow = (float) svalue;
                }
                llSetLinkPrimitiveParamsFast(LINK_THIS,
                    [ PRIM_GLOW, ALL_SIDES, glow ]);

            //  Set light on/off <r,g,b> intensity radius falloff

            } else if (abbrP(sparam, "li")) {
                integer on = onOff(svalue);
                vector colour = llList2Vector(llGetLinkPrimitiveParams(LINK_THIS,
                    [ PRIM_COLOR, ALL_SIDES ]), 0);
                float intensity = 1;
                float radius = 5;
                float falloff = 1;
                if (argn > 3) {
                    colour = (vector) scvalue;
                    if (HSV) {
                        colour = hsv_to_rgb(colour);
                    }
                    if (argn > 4) {
                        intensity = (float) sdvalue;
                    }
                    if (argn > 5) {
                        radius = (float) llList2String(args, 5);
                        if (argn > 6) {
                            falloff = (float) llList2String(args, 6);
                        }
                    }
                }
                llSetLinkPrimitiveParamsFast(LINK_THIS,
                    [ PRIM_POINT_LIGHT, on, colour, intensity, radius, falloff ]);

            //  Set Time tick/change t          Set tick and colour change interval, seconds

            } else if (abbrP(sparam, "ti")) {
                float t = (float) scvalue;
                if (t > 0) {
                    if (abbrP(svalue, "ch")) {
                        polyChangeTime = t;
                    } else if (abbrP(svalue, "ti")) {
                        polyTickLength = t;
                    }
                    polyChangeTicks = (integer) llRound(polyChangeTime / polyTickLength);
                    if (polyChangeTicks < 0) {
                        polyChangeTicks = 1;
                    }
                    if (poly) {
                        polyTicks = 0;
                        llSetTimerEvent(polyTickLength);
                    }
                } else {
                    tawk("Invalid time specification.");
                    return FALSE;
                }

            //  Set trace on/off

            } else if (abbrP(sparam, "tr")) {
                trace = onOff(svalue);

            } else {
                tawk("Invalid.  Set alpha/broadcast/channel/colour/echo/glow/light/time/trace");
                return FALSE;
            }

        //  Status                              Print status

        } else if (abbrP(command, "st")) {
            integer mFree = llGetFreeMemory();
            integer mUsed = llGetUsedMemory();

            string s = llGetScriptName() + " " + llGetObjectName() + " status:\n";

            list l = llGetLinkPrimitiveParams(LINK_THIS,
                [ PRIM_COLOR, ALL_SIDES, PRIM_GLOW, ALL_SIDES, PRIM_POINT_LIGHT ]);
            s += "  Colour: " + efv(llList2Vector(l, 0)) +
                 "  Alpha: " + eFlou(llList2Float(l, 1)) +
                 "  Glow: " + eFlou(llList2Float(l, 2)) +
                 "  Light: " + eFlou(llList2Integer(l, 3));
            if (llList2Integer(l, 3)) {
                s += " (colour " + efv(llList2Vector(l, 4)) + ", " +
                     " intensity " + eff(llList2Float(l, 5)) + ", " +
                     " radius " + eff(llList2Float(l, 6)) + ", " +
                     " falloff " + eff(llList2Float(l, 7)) + ")";
            }
            s += "\n";

            s += "  HSV: " + eFlou(HSV) + "  colourMin: " + efv(colourMin) +
                 "  colourMax: " + efv(colourMax) + "\n";

            s += "  Poly: " + eFlou(poly) +
                 "  polyTickLength: " + eff(polyTickLength) +
                 "  polyChangeTime: " + eff(polyChangeTime) +
                 "  polyChangeTicks: " + (string) polyChangeTicks + "\n";

            s += "  Broadcast:  Send: "+ eFlou(broadcast) +
                 "  Receive: " + eFlou(bcreceive) +
                 "  Channel: " + (string) bcChannel + "\n";

            s += "  Echo: " + eFlou(echo) + "  Trace: " + eFlou(trace) + "\n";

            s += "  Script memory.  Free: " + (string) mFree +
                 "  Used: " + (string) mUsed + " (" +
                    (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)";

            tawk(s);

        //  Test                                Run various tests

        } else if (abbrP(command, "te")) {
            if (argn > 1) {
                //  Test version                Send version check to other components
                if (abbrP(sparam, "ve")) {
                    if (primary) {
                        llRegionSayTo(owner, bcChannel,
                            llList2CSV([ "VERSION", version ]));
                    }
                } else {
                    tawk("Unknown Test item.  Valid: version");
                }
            }

        } else {
            //  Only offer help file if we have it in our inventory
            if (llGetInventoryKey(helpFileName) != NULL_KEY) {
                tawk("Unknown command.  Use /" + (string) commandChannel +
                     " Help for information.");
            }
        }
        return TRUE;
    }

    default {

        on_rez(integer start_param) {
            if (trace) {
                llOwnerSay("on_rez()");
            }
            /*  Performing llResetScript() here guarantees script
                variables are always initialised, regardless of
                how we were instantiated, and forces state_entry()
                to be invoked, even if we were attached from
                inventory.  */
            llResetScript();
        }

        state_entry() {
            whoDat = owner = llGetOwner();
            if (trace) {
                tawk("state_entry()");
            }

            /*  If this component contains the Script Processor,
                it is considered the primary component.  */
            primary = llGetInventoryType(scriptPro) == INVENTORY_SCRIPT;

            //  If a configuration notecard exists, run it now

            if (primary && (llGetInventoryKey(confNotecard) != NULL_KEY)) {
                configuring = TRUE;
                fwdwaited = FALSE;
                llMessageLinked(LINK_THIS, LM_SP_RUN, confNotecard, whoDat);
                if (echo || trace) {
                    tawk("Reading configuration.");
                }
            } else {
                configureComplete();
            }
        }

        //  Attachment to or detachment from an avatar

        attach(key attachedAgent) {
            /*  Place not thy faith in the attach() event, young
                scripter.  Because we llResetScript() in the
                on_rez() event, we'll never see an attach()
                event when we're attached from inventory.  We'll
                only see it in the case of a detach.  The code
                here which handles attach() with a non-null
                argument is purely defensive in case this should
                change in the future.  */
            if (trace) {
                llOwnerSay("Attach " + (string) attachedAgent + " (" +
                    llKey2Name(attachedAgent) + ")");
            }
            if (attachedAgent != NULL_KEY) {
                whoDat = attachedAgent;
                configureComplete();
            } else {
                if (commandH != 0) {
                    llListenRemove(commandH);
                    commandH = 0;
                }
                if (broadcastH != 0) {
                    llListenRemove(broadcastH);
                    broadcastH = 0;
                }
            }
        }

        /*  The listen event handler processes messages from
            our chat control channel.  Note that we only listen
            for messages from the avatar to which we're attached.

            We also receive and process colour change messages
            from a broadcasting component if we're configured to
            receive them.  */

        listen(integer channel, string name, key id, string message) {
            if (trace) {
                tawk(llGetScriptName() + " (" + llGetObjectName() +
                    ") listen.  Channel " + (string) channel +
                    "  message \"" + message + "\"  id " + (string) id);
            }
            if (channel == bcChannel) {
                list m = llCSV2List(message);
                string mtype = llList2String(m, 0);

                if (mtype == "COMMAND") {
                    /*  Forwarded script command from other component.
                        Note that we cannot use the arguments parsed by
                        llCSV2List() because if the message contains a
                        comma unenclosed in brackets, it will incorrectly
                        break the message into multiple list item.  To
                        avoid this, we just extract the entire text
                        from the COMMAND message.  */
                    processCommand(owner,
                        llGetSubString(message, llSubStringIndex(message, ",") + 1, -1), FALSE);
                } else if (mtype == "COLOUR") {
                    //  Colour command from broadcasting component
                    polyLast = (vector) llList2String(m, 1);
                    polyNext = (vector) llList2String(m, 2);
                    polyTickLength = llList2Float(m, 3);
                    polyChangeTicks = llList2Integer(m, 4);
                    HSV = llList2Integer(m, 5);
                    polyTicks = 0;
                } else if (mtype == "VERSION") {
                    //  Version check from primary component
                    string v = llList2String(m, 1);
                    if (v != version) {
                        tawk("Version check failed: primary " + v +
                             " our version " + version);
                    }
                }
            } else {
                //  Command from local chat
                processCommand(id, message, FALSE);
            }
        }

        /*  The link_message() event receives commands from other scripts
            and passes them on to the script processing functions
            within this script.  */

        link_message(integer sender, integer num, string str, key id) {
            if (trace) {
                tawk(llGetScriptName() + " (" + llGetObjectName() +
                    ") link message.  Sender " + (string) sender +
                    "  num " + (string) num + "  str " + str + "  id " + (string) id);
            }

            //  Script Processor Messages

            //  LM_SP_READY (57): Script ready to read

            if (num == LM_SP_READY) {
                scriptActive = TRUE;
                llMessageLinked(LINK_THIS, LM_SP_GET, "", id);  // Get the first line

            //  LM_SP_INPUT (55): Next executable line from script

            } else if (num == LM_SP_INPUT) {
                if (str != "") {                // Process only if not hard EOF
                    scriptSuspend = FALSE;
                    integer stat = processCommand(id, str, TRUE);
                    // Some commands may set scriptSuspend
                    if (stat) {
                        if (!scriptSuspend) {
                            llMessageLinked(LINK_THIS, LM_SP_GET, "", id);
                        }
                    } else {
                        //  Error in script command.  Abort script input.
                        scriptActive = scriptSuspend = FALSE;
                        llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);
                        tawk("Script terminated.");
                    }
                }

            //  LM_SP_EOF (56): End of file reading from script

            } else if (num == LM_SP_EOF) {
                scriptActive = FALSE;           // Mark script input complete
                if (echo || trace) {
                    if (configuring) {
                        tawk("End configuration.");
                    } else {
                        tawk("End script.");
                    }
                }
                if (configuring) {
                    configureComplete();
                    configuring = FALSE;
                }

            //  LM_SP_ERROR (58): Error processing script request

            } else if (num == LM_SP_ERROR) {
                llRegionSayTo(id, PUBLIC_CHANNEL, "Script error: " + str);
                scriptActive = scriptSuspend = FALSE;
                llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);
            }
        }

        //  The timer is used for smooth colour morphing

        timer() {
            if (--polyTicks < 0) {
                polyTicks = polyChangeTicks;

                /*  Unless we're receiving colours from another
                    component, generate the new colour and, if
                    broadcasting, communicate it to other
                    components.  */

                if (!bcreceive) {
                    polyLast = polyNext;
                    polyNext = chooseColour();

                    /*  If broadcast is enabled, send the last and next
                        colours to other components.  */

                    if (broadcast) {
                        llRegionSayTo(owner, bcChannel,
                            llList2CSV([ "COLOUR", polyLast, polyNext,
                                polyTickLength, polyChangeTicks, HSV ]));
                    }
                }
            }
            float oldfrac = ((float) polyTicks) / polyChangeTicks;
            float newfrac = 1 - oldfrac;

            /*  Choose the current colour by interpolating
                between polyLast and polyNext based on the fraction
                of time elapsed between selection of the next
                target colour for each index.  */

            vector ncol = (polyLast * oldfrac) +
                          (polyNext * newfrac);
            if (HSV) {
                ncol = hsv_to_rgb(ncol);
            }
            llSetColor(ncol, ALL_SIDES);
        }
    }
