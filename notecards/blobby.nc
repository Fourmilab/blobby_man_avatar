
                    Fourmilab Blobby Man Avatar

                                   User Guide


In 1987, computer graphics pioneer Jim Blinn published a column in:
    “Jim Blinn's Corner”, IEEE Computer Graphics and Applications,
        October 1987, Page 59.
which was subsequently included in chapter 3 of:
    Blinn, Jim.  Jim Blinn's Corner: A Trip Down the Graphics
    Pipeline.  San Francisco: Morgan Kauffmann, 1996.
    ISBN 978-1-55860-387-5.
The column introduced the “Blobby Man”, a humanoid mannequin built
entirely of sphere primitives organised by hierarchical
transformations.  It dramatically demonstrates how composing rotation,
translation, and scaling transformations permits building realistic
models of complex objects.  An implementation of the Blobby Man was
included in my Simple Graphics Library, developed at Autodesk, Inc. in
March, 1988 to test and demonstrate the 3DMESH facilities in AutoCAD
and subsequently used in demonstrations of other products such as
AutoShade and AutoFlix.

A model of the Blobby Man (inspired by, but not identical to) Jim
Blinn's original, was developed for and included in Fourmilab
Mechanisms for Second Life:
    https://marketplace.secondlife.com/p/Fourmilab-Mechanisms/20515612
Watching the Blobby Man model (with 43 moving parts and seven levels
of hierarchy) perform Second Life animations piqued my interest in
building a Blobby Man avatar that allows computer graphic nostalgia
fans to *become* the Blobby Man when the spirit moves them.

In spirit of retro-technology exemplified by the Blobby Man, instead of
building a fancy mesh avatar which would simply look like the Blobby
Man, I decided to do it all, like the original Blobby Man, with sphere
primitive objects (“prims”), using Second Life avatar attachments to
position and move the components with the avatar.

WEARING THE AVATAR

Due to its construction, wearing the Blobby Man avatar differs somewhat
from using a regular Second Life mesh avatar.  The product delivered to
you from the Marketplace contains two folders:
    Blobby Man Avatar: Unscripted (Replace Current Outfit)
    Blobby Man Avatar: Scripted (Replace Current Outfit)
We'll start with the simpler Unscripted avatar.

Start by wearing one of the standard Second Life avatars (if your
current outfit has been customised, be sure to save it before switching
to a standard avatar; otherwise your changes will be lost).  As the
avatar will be entirely hidden by the Blobby Man avatar, it doesn't
matter which one you choose.

Next, find the “Blobby Man Avatar: Unscripted (Replace Current Outfit)”
folder in your inventory.  Highlight the folder, right click, and
select “Replace Current Outfit”.  The standard avatar should disappear
and be replaced by the Blobby Man avatar.  Now try walking, sitting,
and other motions to see your new avatar in action.  Finally, play some
of the standard gestures from the Comm/Gestures menu, such as “dance1”:
the avatar should respond to the animation.  (If animations don't play,
it's probably because you inherited an “Animation Overrider” from the
standard avatar you wore.  Check the “Current Outfit” in your
inventory.  If you see something like “Animation Overrider - Female”,
right click it and select “Detach From Yourself”.  With the overrider
gone, gestures and animations should now work.)

Now go to the Appearance dialogue, select Outfit Gallery, and save your
Blobby Man outfit with “Save As” so you'll be able to easily restore it
whenever you wish.

USING THE SCRIPTED BLOBBY MAN

In the example above, we used the basic, unscripted Blobby Man.  This
version is simple and imposes a very light load on the simulator.  The
scripted version allows you more flexibility in configuring the avatar
to your preferences, including animated colour changes.  Start by
creating a new outfit and wearing the avatar components as above,
except this time select the folder “Blobby Man Avatar: Scripted
(Replace Current Outfit)”.  Initially, the avatar will look and behave
identically, but you can now customise it via commands in local chat.
Commands are sent on channel 1987, the year Jim Blinn introduced the
original Blobby Man.  For example, to change the colour of the avatar
to red, enter the command in local chat:
    /1987 set colour <1, 0, 0>
(Commands and arguments may be entered in either upper or lower case,
and may be abbreviated to as few as two characters.)

Here is a list of available commands.  The chat channel number is
omitted in the interest of concision.

    Boot
        Reset the scripts in all components.  If you have changed
        the chat command channel, this will restore it to the
        default of 1987.

    Clear
        Print white space in local chat.

    Kill scripts
        Delete the scripts from all Blobby Man components.  After you
        enter this command, no further commands will be accepted, as
        the scripts which process them will be gone.  After you've
        made a custom configuration and are satisfied with the results,
        you can use this command to freeze your changes and prevent
        further modifications and also reduce the load your avatar
        places on the simulator.

    Panic [ gently ]
        Restore all components of the avatar to the standard settings,
        If “gently” is specified, a running script will not be
        interrupted; otherwise any running script(s) will be
        terminated.

    Script
        Execute commands from a script stored in a notecard in one of
        the avatar's components.

        Script list
            List scripts in the component's inventory.  All script
            notecards have names which begin with “Script: ”.

        Script run name
            Run the named script (specified without the leading
            “Script: ”).  The name must be specified precisely as in
            the inventory, with upper and lower case letters, spaces,
            and without abbreviation.  Specifying “Script run” with no
            name terminates the currently running script.

        Script pause n
            Pause execution of the script for n seconds.

    Set
        Set a variety of parameters.

        Set alpha on/off/n
            Set the transparency of components.  You can specify “on”
            to display them as solid objects, “off” to hide them
            entirely, or a numeric value between 0 (transparent) and 1
            (solid) for intermediate settings.

        Set broadcast send/receive/channel
           Controls broadcasting of colour information from a master
           component (usually the Body) to other components to
           accomplish smooth colour changes of the entire avatar.  To
           enable smooth changes, in the master component use:
                Set broadcast send on
            and in all components which should change along with it:
                Set broadcast receive on
            Colour broadcast information is sent by default on channel
            -982449802, which you can change, should you wish, with
            “Set broadcast channel n” where n is the channel.  To
            disable broadcast, specify “off" instead of “on” in the
            appropriate command(s).

        Set channel n
            Set the channel on which the avatar listens for commands in
            local chat to channel n.  If you subsequently reset the
            script with the “Boot” command or manually, the chat
            channel will revert to the default of 1987.

        Set colour
            Set various parameters associated with colours.
                Set colour HSV
                    Specify colours in the HSV (Hue, Saturation, Value)
                    system.  All values are specified as numbers
                    between 0 and 1, with hue values between 0 and 1
                    representing the range from zero to 360 degrees on
                    the colour wheel.
                Set colour minimum <a, b, c>
                    Set the minimum colour component values used when
                    choosing random colours.  The <a, b, c> values
                    represent red, green, and blue channels if the
                    default RGB colour system is in effect, or hue,
                    saturation, and value if HSV is selected.
                Set colour maximum <a, b, c>
                    Set the maximum colour component values used when
                    choosing a random colour, in RGB or HSV as
                    described above.
                Set colour poly
                    Automatically change colours smoothly to random
                    colours selected between the minimum and maximum
                    values described above.  When “Set colour poly” is
                    in effect, you must not delete scripts with “Kill
                    scripts”, as that would freeze the current colours
                    in place.  Setting colour to any fixed value stops
                    automatic changing by poly mode.
                Set colour random
                    Set colour to a random colour chosen from the
                    minimum and maximum specified as above.  Every
                    time you specify random, you'll get a different
                    colour, but colours will not subsequently change
                    as they do with “poly”.
                Set colour RGB
                    Specify that colour components are given as red,
                    green, and blue (the defaults).
                Set colour Simpsons
                    Set colour to “Simpsons yellow”, <1, 0.851, 0.059>.
                Set colour Standard
                    Set colour to default: <0.788, 0.58, 0.455>.
                Set colour <a, b, c>
                    Set colour to the specified components, in the RGB
                    or HSV system as selected.

        Set echo off/on
            Controls whether commands entered from local chat or a
            script are echoed to local chat as they are executed.

        Set glow off/on/n
            Sets the glow parameter off, on, or an intermediate value
            specified by a number between 0 (none) and 1 (intense).

        Set light on/off <a, b, c> intensity range falloff
            Set the component as a point light source (or turn it off),
            with the specified colour (in RGB or HSV, as set by “Set
            colour”), and the intensity (1), range (5), and falloff (1)
            parameters given (defaults in parentheses).  The settings
            are as used in the PRIM_POINT_LIGHT prim parameter:
                http://wiki.secondlife.com/wiki/PRIM_POINT_LIGHT

        Set time tick/change t
            When “Set colour poly” is in effect, set the time between
            incremental colour steps (tick) or choice of a new colour
            (change) to t in seconds.

        Set trace on/off
            Enable or disable output, sent to the owner on local chat,
            describing operations as they occur.  This is generally
            only of interest to developers.

    Status
        Show status of script(s), including settings and memory usage.

    Test version
        Verify that all components are running the same version of the
        Blobby Man script.  This is intended for developers who modify
        the script and wish to confirm the most recent version has been
        installed in every body part.  Any discrepancies are reported
        on local chat.  If the checks are successful, no output is
        generated.

Directing Commands to Components

    By default, when you enter a command in local chat, it will be
    received by and processed by all components of the avatar.  You
    can, if you wish, direct a command to a limited set of components
    by naming them, followed by a colon, at the start of the command.
    To see the names of the components, display the contents of the
    folder containing them in your inventory.  For example, to set
    just the head of the avatar to “Simpsons yellow”, use:
        Head: Set colour Simpsons
    To set both feet brown, specify:
        Left Foot, Right Foot: Set colour <0.514, 0.361, 0.231>

Submitting Commands from Scripts

    The Body component of the Blobby Man avatar contains a copy of the
    Fourmilab Script Processor which allows commands to be specified
    from a notecard in the component's inventory.  Commands are
    specified precisely as they are given in local chat (without,
    of course, the chat channel number specification).

    Commands within a script are executed, by default, only by the
    component containing the script.  You can direct commands to other
    components by naming them before the command as described below.  A
    component specification of “*” sends the command to all components,
    including the one running the script, while a blank component
    specification sends the command to all components except the one
    running the script.  For example, the following script sets the
    entire avatar grey, the head red, and all components except the
    body glowing.
        *: Set colour <0.75, 0.75, 0.75>
        Head: Set colour <1, 0, 0>
        : Set glow 0.1

    If you place a notecard named “Blobby Man Configuration” in a
    component with the Script Processor (normally the Body), the
    commands in it will be executed automatically when the avatar is
    attached or the script reset with the “Boot” command.  This allows
    you to, for example, change the channel on which all components
    listen without having to individually edit the scripts in every
    component.

    Several sample scripts are included with the scripted version of
    the Blobby Man avatar.  All are placed in the primary component,
    “Body”.  The “Script list” command lists available script, and any
    of the scripts may be run with “Script run” followed by the script
    name exactly as it is given in the list.
        Chroma      All body parts randomly change colour together.
        Ghost       Transform the avatar into a glowing,
                    semi-transparent ghost.
        Melanin     The avatar will smoothly change among a variety of
                    skin colours of human populations.
        Motley      All components change colour independently, at
                    random.
        Rainbow     Body parts are coloured in the shades of the
                    rainbow from head to feet.
        Red head    Example from above: grey, glowing (except for the
                    Body component), with a red head.
        Shades      Illustrates a variety of skin colours, looping
                    three times through them.
        Sparkle     Switch rapidly among bright, saturated colours.
        Torchman    Glowing golden body, illuminating objects nearby.

Saving Modified Versions of the Avatar

When you wear the scripted Blobby Man avatar and modify its settings,
the modifications are made directly to the components in the folder
from which you added them to your outfit.  Since you may wish to make a
different custom version starting from the standard settings, it's wise
to first make a copy of the entire “Blobby Man Avatar: Scripted
(Replace Current Outfit)” folder, rename it to something which
identifies it, and then wear its components and modify them as you
like.  That way, the original copy will not be changed and can serve as
the starting point for other custom versions.  This is particularly
important if you use “Kill scripts” to delete the scripts in your
custom version, as you won't be able to subsequently modify it with
chat commands.  If you do inadvertently wreck your original copy of the
Blobby Man avatar, just request a redelivery from the Fourmilab store
in the Second Life marketplace: like the original avatar, redelivery is
free.

QUESTIONS AND ANSWERS

Why doesn't the Blobby Man have eyes or ears?
    Because it's an homage to Jim Blinn's original model, which lacked
    these appendages.  Consider adding them as a project to learn more
    about modeling in Second Life.

In some extreme motions, gaps open between the body parts.  Can't you
keep it together?
    Unlike a mesh model, where the body stretches as it moves, the
    body part components of the Blobby Man are rigid objects.  In
    extreme extensions, gaps will open between adjacent components.
    This is normal.

Is the Blobby Man a he or a she?
    It's an it.  “Man” is used in the generic sense of a humanoid
    figure.

Can I add clothes to the Blobby Man?
    Sure, but be careful to Add to the existing outfit, as opposed to
    using Wear, which is likely to replace one of the Blobby Man's body
    parts with the item you're attaching.  Depending upon the shape of
    the garment, some parts of the Blobby Man body may “poke through”.
    You can work around this to some extent by making those body parts
    invisible with the “Set alpha off” command, but this does not
    provide as fine-grained control as with mesh bodies or alpha masks
    on standard avatars (which do not work with the Blobby Man
    components).

Can I texture the Blobby Man components?
    Yes!  When adding a texture (for example, a face to be wrapped
    around the Head component), you'll probably want to set the prim's
    colour to white so as not to interfere with colours in the texture
    map.  Recall that every component of the Blobby Man is a sphere
    prim, scaled appropriately for its function.  If you're wrapping a
    cylindrical projection texture around the prim, you'll need to
    rotate it 90 or 270 degrees so it aligns properly with the surface.

Somebody looked at my avatar and said I had more than 20 scripts
running.  What's with that?
    Since each body part is a separate attachment, the scripted version
    of the Blobby Man avatar must have a copy of the control script in
    every one, which adds up to 22 scripts for the complete avatar.
    You wouldn't think this to be a problem, since the scripts spend
    almost all of their time idle, waiting for a command.  But due to
    how Linden Scripting Language is implemented, idle scripts consume
    simulator resources and, in crowded venues, may lead to lag and
    chiding from tech-savvy others.  (The unscripted version of the
    avatar has, as you might guess, no scripts at all and won't cause
    any such problems.)

    When you're configuring a custom avatar, the best practice is to
    get everything set to your satisfaction, save the outfit and a copy
    of your configured components, and then delete the scripts in all
    of them with the “Kill scripts” command.  After you do this,
    however, you won't be able to use commands to further configure the
    avatar, which is why you should always save a copy before deleting
    the scripts.  Then, if you want to make another change, you can go
    back to the saved scripted version, modify it as you wish, and then
    update the version with scripts removed.

I'm looking for a more realistic inexpensive, full-permissions avatar.
Any suggestions?
    Check out the Ruth:
        https://marketplace.secondlife.com/p/Blackburns-BOM-Ruth-with-v4-Head-2021-plus-Alpha-HUD/20778485
    and Roth:
        https://marketplace.secondlife.com/p/Roth2-v2-BOM-Bento-RAW-Adult-Version/19846204
    avatars.  I have nothing to do with these products, and their links
    in the Marketplace may change over time.

PERMISSIONS AND THE DEVELOPMENT KIT

The Fourmilab Blobby Man Avatar is delivered with "full permissions".
Every part of the object, including the scripts, may be copied,
modified, and transferred subject only to the license below.  If you
find a bug and fix it, or add a feature, let me know so I can include
it for others to use.  The distribution includes a “Development Kit”
directory, which includes all of the components (for example, the alpha
mask and shape definition) of the model.

The Development Kit directory contains a Logs subdirectory which
includes the development narratives for the project.  If you wonder
"Why does it work that way?" the answer may be there.

Source code for this project is maintained on and available from the
GitHub repository:
    https://github.com/Fourmilab/blobby_man_avatar

LICENSE

This product (software, documents, images, and models) is
licensed under a Creative Commons Attribution-ShareAlike 4.0
International License.
    http://creativecommons.org/licenses/by-sa/4.0/
    https://creativecommons.org/licenses/by-sa/4.0/legalcode
You are free to copy and redistribute this material in any
medium or format, and to remix, transform, and build upon the
material for any purpose, including commercially.  You must give
credit, provide a link to the license, and indicate if changes
were made.  If you remix, transform, or build upon this
material, you must distribute your contributions under the same
license as the original.
