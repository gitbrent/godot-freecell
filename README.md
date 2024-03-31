# Godot FreeCell

## ℹ️ About

Godot FreeCell is a classic solitaire card game built with the Godot Engine, designed to offer a clean and enjoyable gaming experience free from ads or unnecessary distractions. This game is developed using GDScript and uses free assets from [itch.io](https://itch.io/), ensuring an engaging gameplay experience with a touch of artistic flair. With support for desktop, iOS, and Andriod you can enjoy FreeCell Solitaire on your favorite devices.

<p align="center">
  <table>
    <tr>
      <td>
        <a href="https://github.com/gitbrent/godot-freecell/">
          <img alt="FreeCell Solitaire Gameplay on iPad" title="FreeCell Solitaire Gameplay" src="https://github.com/gitbrent/godot-freecell/assets/7218970/269d1d39-ecf0-4fe6-b925-ee6f513a56a4" width="400"/>
        </a>
      </td>
      <td>
        <a href="https://github.com/gitbrent/godot-freecell/">
          <img alt="FreeCell Solitaire Gameplay on iPad" title="FreeCell Solitaire Gameplay" src="https://github.com/gitbrent/godot-freecell/assets/7218970/3fc0f9ca-9ea3-4ded-94c8-212a3d653244" width="400"/>
        </a>
      </td>
    </tr>
  </table>
</p>
<br/>

## 🎮 How to Play

- Start the game from the main menu by clicking "Start."
- Move cards according to the classic solitaire rules.
- The objective is to move all cards to the foundation piles, sorting them by suit and in ascending order.
- More detailed rules and history of the game can be found on [Wikipedia](https://en.wikipedia.org/wiki/FreeCell)

## 🔌 Installation

To run FreeCell Solitaire on your local machine, you'll need to have Godot Engine installed. You can download Godot Engine from [here](https://godotengine.org/download).

After installing Godot, follow these steps:

1. Clone this repository to your local machine.
2. Open Godot Engine and import the project.
3. Press 'Play' to run the game.

## 📱 Exporting to iOS

Exporting FreeCell Solitaire to iOS is straightforward, requiring only Xcode, Apple’s integrated development environment. You do not need an Apple Developer license to sideload the game onto your own device for personal use. Here’s how you can get your game running on an iOS device:

### Prerequisites

- **Xcode:** Ensure you have the latest version of Xcode installed on your Mac. You can download it for free from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835).
- **Godot Export Templates:** Download and install the export templates for iOS from within the Godot Engine. This can be done by going to `Editor` > `Manage Export Templates` in the Godot Engine menu.

### Steps

1. **Export Project in Godot:**
   - Open your project in Godot Engine.
   - Go to `Project` > `Export` and select `Add…` to add a new export preset.
   - Choose `iOS` from the list and configure the export settings as needed. For most cases, the default settings will suffice.
   - Click `Export Project`, choose a destination, and save your `.ipa` file.

2. **Sideloading with Xcode:**
   - Open Xcode and navigate to `File` > `Open` to open the `.ipa` file you exported.
   - Connect your iOS device to your Mac via USB.
   - Select your device from the list of available targets in Xcode.
   - Navigate to `Window` > `Devices and Simulators`, and under the “Installed Apps” section, drag and drop your `.ipa` file to install the game on your device.

3. **Trust Developer App:**
   - On your iOS device, go to `Settings` > `General` > `Device Management`.
   - Under "Developer App", tap your Apple ID and then trust it.
   - You should now be able to open the game on your device.

### Notes

- While you don't need an Apple Developer account for personal use, distributing your game on the App Store or to a broader audience requires a membership in the Apple Developer Program.
- Sideloading with Xcode installs the game only on connected devices and is ideal for testing or personal use.
- Remember to check the [official Godot documentation](https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_ios.html) for any updates or changes to the export process.

With these steps, you can enjoy FreeCell Solitaire on your iOS device without any cost. Happy gaming!

## 📜 License

Godot FreeCell is available under the MIT License, which allows for both personal and commercial use, modification, distribution, and private use. For more details, please see the [LICENSE](LICENSE) file.

## 🙏 Acknowledgements

- Game development powered by [Godot Engine](https://godotengine.org/).
- Free assets used in this game were sourced from [itch.io](https://itch.io/).
- A big thank you to the Godot and open-source communities for their invaluable resources and support.
