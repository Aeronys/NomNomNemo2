# Nom Nom Nemo

## Summary

This is my submission for CS50x's final project. In week 0 of the class, I created a simple fish game in Scratch, in which you would swim around the screen trying to eat smaller fish and avoid being eaten by bigger fish. This was all contained to a small, static playing area. My aim with this project was to imagine how this initial game could be expanded on and put that into being. In this new version of Nom Nom Nemo, the play area is much bigger, and the game has become a side scroller as you explore the ocean.

There are also multiple types of fish that exhibit different behaviours. A leveling system has also been added into the game, where instead of simply growing bigger with each fish the player eats, players now gain experience and level up at certain experience breakpoints. On level up, the player is presented with different upgrade options, allowing the player to choose how they would like to grow their fish's abilities.

A detection and stealth system has also been implemented, where fish react to the player and enemy fish coming within a certain proximity of each other. At this point the fish will either become alert, giving the player a warning before the fish begins to pursue the player, or, if the player is larger, the enemy fish will begin to retreat right away. The player can reduce the distance at which they're detected and at which enemy fish give up chasing them by increasing their stealth level. Certain types of fish are exempt from this detection system and have their own unique behaviour.

Finally, a win condition has been added to the game, where the player is declared victorious after successfully eating a certain type of fish, the eel.

## How to Play

Swim around the ocean, trying to eat fish that are smaller than you while avoiding fish that are bigger than you. Level up to improve your abilities so that you can eat bigger, more valuable fish, until you beat the game by finally managing to eat an eel. After beating the game you have the option of either continuing to play, endlessly eating fish around you (or being eaten yourself), or reseting the game and playing again.

## Game Controls

**Movement** - wsad or arrow keys

**Pause** - p, space, or esc

**Mute music** - m

## Types of enemy fish

**Basic Fish** - These fish are a pink-purple color, and are the first types of fish you encounter in the game. They are meant to give a starting point into gameplay.

**Stealth Fish** - These blue fish are very difficult to see until you get close to them. When getting close, if they are bigger than you they become much more visible as soon as they are alerted to your presence. If they are smaller than you, they become even more difficult to see as they try to escape you. The player can choose an upgrade to make stealth fish easier to see.

**Green Fish** - These fish move more frequently than other types of fish, and are speedier than basic fish and stealth fish. They don't have any particularly unique behaviour, but are meant as a stepping stone to both serve as a perceived threat in the early game, and an opportunity to attain experience more quickly in the mid game.

**Puffer Fish** - These fish are unique in a number of ways. Most important being that they can not be eaten no matter the player's size, unless the player gets a specific upgrade allowing them to eat Puffer Fish. Upon acquiring this upgrade they can be eaten like normal if the player is larger than them. 

The other feature of puffer fish that sets them apart from other fish in the game is their movement. Puffer fish will only oscillate up and down, and will never move to the left or to the right. They also do not detect the player or attempt to chase.

For collision purposes puffer fish are considered to be only 95% of their actual size, to make things a little more forgiving with the player having to judge whether they are bigger or not. This was done in consideration of both the fact that they have a more unique shape than most fish in the game, making their size a little more difficult to judge, and the fact that they do not become alert when the player nears them, providing the warning that other fish provide to let the player know that they are a danger.

**Big Fish** - These large, redc fish are the end game fish. They do not move very quickly or frequently when they are in their neutral state, but they have a very large detection range, and when they do detect the player they move very quickly. These fish are the greatest threat in the game, but also a great source of experience points.

**Eel** - The final fish of the game. These fish do not begin to spawn until the player reaches level 18. They are normally inedible to the player, but at level 20 the player is given an upgrade that enables them to eat eels. Eating an eel is the win condition for the player.

Throughout the game, eels will neither chase or retreat from the player, but their movement is randomized, and they move at incredibly fast speeds. Until getting the Eel Slurper upgrade, the player must be very wary wary around eels, not to accidentally get caught up in its path

## Types of upgrades

**Size up** - Increase the size of the player, thus allowing him to eat bigger fish

**Speed up** - Increase the speed of the player, allowing him to better chase down smaller fish, and evade larger fish

**Stealth up** - Decreases both the range at which enemy fish will detect and begin to chase or retreat from the player, and the distance a player needs to attain from a larger fish before it will stop chasing the player

### Special Upgrades

**Observant** - Enables the player to see stealth fish much more easily

**Puffer Popper** - Enables the player to eat puffer fish, so long as they are smaller than the player

**Predator** - Enables the player to eat fish that are up to 10% larger than the player

**Eel Slurper** - Enables the player to eat eels of any size, which is necessary to win the game

## Implementation

This game was developed with the LÖVE framework and Lua scripting language. I used the tutorials at https://sheepolution.com/learn/book/contents to familiarize myself with the LÖVE framework, followed by the tutorials at https://simplegametutorials.github.io/ for practice and inspiration.

I used an object oriented approach to designing this game, which was made possible with the classic.lua file. The code in classic.lua was not created by me, but was taken from Github, as is attributed in the comments preceding the code. All sources will be listed at the end of this readme.

**main.lua** - Our main game file, required by Lua. It contains most of the functionality for generating the game level, and is responsible for creating the player and enemy fish. This is also where all the functionality for button presses and mouse clicks are found, as well as the function for printing game screens and resolving collisions. I put the resolveCollision function in this file, since this is where both the enemy fish table and the player object are generated, but in the future I may like to move this into either the fish or the player class, as it seems more appropriate there.

**entity.lua** - A short bit of code giving us a base object for any physical entities we will see on screen.

**fish.lua** - Our base fish class. This class inherits the properties of the entity class, and is inherited by all the types of fish we might make in the game. As it is, it serves as the template for our basic fish type, and contains the default behaviours of fish in the game, such as animation, movement, and player detection. It also contains some needed functions for determining more accurate hitboxes for fish and checking game boundaries, preventing the player and enemy fish from appearing more distant from each other than they really are due to being on different canvases. (i.e. Player x is 5499 and enemy fish x  is 1. Without checking boundaries, the game would report the distance as being 5498, but by checking the boundaries it is able to correctly report the distance as being 2.)

**player.lua** - The player is a fish, and so shares many properties with the fish class. Therefore we have it extend the fish class. Player is distinct from fish in that it is player-controlled, so we add movement controls, which in turn call the inherited moveFish function from the fish class. The player can also level up, so it is given functions to process XP and level up. The checkCollision function is also found in the player class, since all collisions in the game will involve the player. This class also includes a number of variables that are unique to the player.

**alert.lua** - This is a short bit of code that inherits our entity class. This allows us to easily assign an image to it, as well as including some timer variables that are used specifically for alerts. This class will be called every time an enemy fish larger than the player becomes alerted to the player's presence.

**stealthFish.lua** - Inherits the fish class. Is distinct in that it has a variety of color settings based on what state it's in. Also has its own draw function to allow it to change colors based on its current state, as well as functions to change color scheme based on whether or not the player has the upgrade to see stealth fish more easily.

**greenFish.lua** - Inherits the fish class, and then simply gives itself some distinct values to reflect its own distinct class, such as size, speed, xp, etc. There is not a lot that is unique about this fish, other than the fact that it moves around quite frequently, as reflected by its moveFrequency variable being set lower than other fish.

**pufferFish.lua** - Inherits the fish class. PufferFish has its own animateFish function, superseding the one in fish.lua, since puffer fish are only able to oscillate up and down. The realSize variable is also adjusted here, to make puffer fish a little more forgiving when judging whether or not the player is bigger than the enemy puffer fish.

**bigFish.lua** - Inherits the fish class. Nothing too special happens in this file, other than assigning big fish their own distinct values.

**eel.lua** - Inherits the fish class. Eel movement is unique and quite different from other fish, so it gets both its own animateFish and moveFish functions. While most fish simply move up, down, left, or right, eels are able to move at a variety of angles, and so their movement is calculated using sin and cos functions.

**upgrades.lua** - Class containing all of the possible player upgrades. The player entity will have a variable referencing the upgrades class, in order to track the various upgrades. Within this class we find functionality to draw the upgrade table, to choose upgrades, and what to do for any given upgrade chosen by the player. We also find here the sound effects for various upgrade selections.

**windows.lua** - Provides functionality to draw information windows on the screen. This is used by the drawPause, drawVictory, and Upgrades:draw functions. This class allows us to draw the base window, draw lines of text within the window, and draw buttons in the window. This class is helpful in that when we draw lines or buttons, the class will determine where they should be in relation to the window rather than our having to do the calculations based on our window placement every time.

**classic.lua** - Enables us to use classes in Lua. None of this code was written by me, as it was taken from https://github.com/rxi/classic

**conf.lua** - Basic conf file

## Development Challenges

The greatest challenge by far was scope creep. As I worked on the game, things kept coming up that I felt could improve the game. As a result, I ended up spending a lot more time on this final project than I had initially intended, although I thoroughly enjoyed working on it, and I had to make some hard decisions on what to implement and what to leave out so that I could actually come to an end point and submit this final project.

For example, initially the pause feature was very simple, and just put all gameplay on hold. I decided it would be nice to have a way of tracking the player's upgrades though, and ended up implementing a pause screen to display the player's current upgrade status. Another feature that came in later was the implementation of the eel as a win condition. Initially the game was intended to just go on endlessly, but I decided that a win condition was needed, so the eel was added to the game.

Some features didn't end up being implemented, but I'd like to consider adding them in later should I ever come back to working on this game. I had thought it would be interesting to make the "big fish" of the game behave uniquely by instead of having them hold still during their alert timer, they could instead slowly accelerate towards the player until reaching their max speed. Another feature I might like to add in the future is instead of having the "eel slurper" upgrade be something you attain by hitting level 20, it could be a pickup found at the very bottom of the ocean. I was considering this because I found that with the bottom of the ocean being so dangerous, I usually ended up beating the game without ever reaching the bottom. Adding this pickup requirement to be able to eat eels could make the game more interesting by forcing players to reach the bottom in order to be able to beat the game. There were many other small features that were not implemented due to time constraints, such as more advanced audio/volume controls, and a separate buttons class.

Another challenge was deciding when it was appropriate to create a new class, and which classes to put which functions into. Some of these challenges have been previously mentioned, such as the decision to put the ResolveCollision function into main.lua, and the decision to not make a separate buttons class. I'm somewhat satisfied with the decisions I've made, but do feel some regret at the way I implemented resolveCollision, as I feel it would've been more appropriate to include it as part of the player class.

## Credits

### Code

classic.lua - https://github.com/rxi/classic

function gradientMesh(dir, ...) - https://love2d.org/wiki/Gradients

### Images

Almost all images came from https://kenney.nl/assets/fish-pack

### Audio

aquarium-fish-132518.mp3 - https://pixabay.com/music/beats-aquarium-fish-132518/

waves.wav  - https://freesound.org/

buttonClick.wav - https://freesound.org/people/Breviceps/sounds/448081/

All other audio files were created by myself using https://jfxr.frozenfractal.com/ and Audacity

**A big thank you to Harvard Online and David Malan for making the CS50 course so readily available, accessible, and enjoyable. I absolutely loved it.**


