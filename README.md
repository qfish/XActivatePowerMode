# XActivatePowerMode

An Xcode plug-in makes [activate-power-mode](https://github.com/JoelBesada/activate-power-mode) happen in your Xcode.

<!-- FOR FUN, BE HAPPY! Dont be too serious, Man~~ -->

<img src="http://7d9o0x.com1.z0.glb.clouddn.com/XActivatePowerMode/behappy.png" width="300"/>

**NOTE THAT THIS VERSION IS VERY BUGGY RIGHT NOW**

<!--
<b style="color:#00C0FF; font-size:64px;">F</b>
<b style="color:#0DB3FF; font-size:64px;">O</b>
<b style="color:#1AA6FF; font-size:64px;">R</b>
<b style="color:#2799FF; font-size:64px;">&nbsp;</b>
<b style="color:#348CFF; font-size:64px;">F</b>
<b style="color:#417FFF; font-size:64px;">U</b>
<b style="color:#4E72FF; font-size:64px;">N</b>
<b style="color:#5B65FF; font-size:64px;">,</b>
<b style="color:#2799FF; font-size:64px;">&nbsp;</b>
<b style="color:#754BFF; font-size:64px;">B</b>
<b style="color:#823EFF; font-size:64px;">E</b>
<b style="color:#2799FF; font-size:64px;">&nbsp;</b>
<b style="color:#9C24FF; font-size:64px;">H</b>
<b style="color:#A017FF; font-size:64px;">A</b>
<b style="color:#A00AFF; font-size:64px;">P</b>
<b style="color:#A000FF; font-size:64px;">P</b>
<b style="color:#A000FF; font-size:64px;">Y</b>
<b style="color:#2799FF; font-size:64px;">&nbsp;
<b style="color:#A000FF; font-size:64px;">!</b>
-->

## Effects

* Default

    <img src="http://7d9o0x.com1.z0.glb.clouddn.com/XActivatePowerModepreview.gif" width="500"/>

* Bloody (Thanks to @gavinkwoe)

    <img src="http://7d9o0x.com1.z0.glb.clouddn.com/XActivatePowerMode/effect-bloody.gif" width="500"/>

* [**🎉 Find More**](https://github.com/qfish/XActivatePowerMode#make-your-own-particle-effect)

## How to install and use?

### Terminal

```sh
git clone https://github.com/qfish/XActivatePowerMode.git && cd XActivatePowerMode && xcodebuild clean > /dev/null && xcodebuild > /dev/null
```

### [Alcatraz](http://alcatraz.io)

Install Alcatraz followed by the instruction (search `XActivatePowerMode`), restart your Xcode and it works by default.

### Manually
Clone the repo, then build (<kbd>cmd + b</kbd>) the `XActivatePowerMode` target in the Xcode project and the plug-in will automatically be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`. Relaunch Xcode and it will work too.

## Deactivate Tips

The switch is under the menu <kbd>Edit</kbd> -> <kbd>Activate Power Mode</kbd>, just click that or **uninstall this plug-in** :] .

<img src="http://7d9o0x.com1.z0.glb.clouddn.com/XActivatePowerMode/tips.png" width="500"/>


## Make your own particle effect?

The default effect was builded with [UIEffectDesigner](http://www.touch-code-magazine.com/uieffectdesigner/). Make your own `ped` effect file, then add it to the project. The name of it will show in the <kbd>effects menu</kbd> list.

Its appreciated that you **pull** a **request** with your **EFFECT**.

## TODO

* **8bit BGM** 🔔 (Wishlist)
* Performence and Stability
* More feature as [activate-power-mode](https://github.com/JoelBesada/activate-power-mode)

## License

XActivatePowerMode is published under MIT License. See the LICENSE file for more.

## Special thanks to

* [![Geek-Zoo](http://geek-zoo.com/img/images/logo_2.png)](http://www.geek-zoo.com)

  They provide awesome design and development works continues to help the open-source community even better.
