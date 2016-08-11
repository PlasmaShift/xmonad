import           System.IO
import           XMonad
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Layout.NoBorders
import           XMonad.Hooks.FadeInactive
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Util.EZConfig
import           XMonad.Util.Run
import           Graphics.X11.ExtraTypes.XF86

import           XMonad.Prompt
import           XMonad.Prompt.Input
import           XMonad.Prompt.RunOrRaise
import           XMonad.Prompt.Shell
import           XMonad.Prompt.Window
import           XMonad.Prompt.AppLauncher as AL
import           XMonad.Prompt.Layout



-- transparent inactive windows needs FadeInactive
myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.8

-- shell prompt theme
mySP = defaultXPConfig
       { font = "xft:DejaVu Sans Mono:pixelsize=14"
       , bgColor           = "#0c1021"
       , fgColor           = "#f8f8f8"
       , fgHLight          = "#f8f8f8"
       , bgHLight          = "steelblue3"
       , borderColor       = "DarkOrange"
       , promptBorderWidth = 1
       , position          = Top
       , height            = 22
       , defaultText       = []
       }

myAutoSP = mySP { autoComplete       = Just 1000 }
myWaitSP = mySP { autoComplete       = Just 1000000 }


main = do
  xmproc <- spawnPipe "compton"
  xmproc <- spawnPipe "feh --bg-fill ~/Downloads/fleet.jpg"
  xmproc <- spawnPipe "xmobar /home/PlasmaStrike/.xmonad/xmobar.hs"
  xmonad $ defaultConfig
     { modMask    = mod4Mask
     , layoutHook = smartBorders . avoidStruts $ layoutHook defaultConfig
     , manageHook = manageDocks <+> (isFullscreen --> doFullFloat) <+> manageHook defaultConfig
     , logHook = myLogHook <+> dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 50}

     -- , manageHook = composeALL [
     --         manageDocks
     --       , isFullscreen --> doFullFloat
     --       , className =? "Vlc" --> doFloat
     --       , manageHook defaultConfig
     --      ]

     }


     `additionalKeysP`
     [
       ("M-e", spawn "emacsclient -c")
     , ("M-r M-r", spawn "sh ~/emacs/emacsdistro.sh spacemacs")
     , ("M-r M-e", spawn "sh ~/emacs/emacsdistro.sh master")
     , ("M-f", sendMessage ToggleStruts)

     --volume
     , ("<XF86AudioLowerVolume>", spawn "amixer set Master on && amixer set Headphone on && amixer set Master 2-")
     , ("<XF86AudioRaiseVolume>", spawn "amixer set Master on && amixer set Headphone on && amixer set Master 2+")
     , ("<XF86AudioMute>", spawn "amixer set Master toggle && amixer set Headphone toggle")

    -- prompt
    , ("M-o r", shellPrompt mySP) -- shell prompt
    -- , ("M-o t", prompt (myTerminal ++ " -e") mySP) -- run in term
    , ("M-o g", windowPromptGoto myWaitSP) -- window go prompt
    , ("M-b", windowPromptBring myWaitSP) -- window bring prompt
    , ("M-o d", AL.launchApp mySP { defaultText = "~" } "thunar" ) -- thunar prompt
    , ("M-v", windowPromptGoto myWaitSP)
    -- , ("M-v", windowPromptBring myWaitSP)
    , ("M-c", kill)
    -- , ("M-<Return>", runOrRaise "gmrun" (className =? "Gmrun")) -- gmrun

    ]
