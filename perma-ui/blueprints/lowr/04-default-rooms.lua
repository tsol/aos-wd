-- CITY
CentralHub = '/1000-1000-1000'

-- Additional Rooms for more detailed city exploration
createRoom(CentralHub, 's', 'Market Street', [[
  
    Market Street is lined with stalls selling everything from exotic spices to handmade trinkets. The air is filled with the
    sounds of haggling and the scent of street food. It's a vibrant and colorful area, always bustling with activity.
  
]])

C = createRoom(CentralHub, 'e', 'Artisan Alley', [[
  
    Artisan Alley is a narrow street filled with workshops and galleries. You can watch craftsmen at work, creating beautiful
    pieces of art and furniture. The atmosphere is creative and inspiring, with the sound of tools and the sight of masterpieces in the making.
  
]])

C = createRoom(C, 'e', 'Historic District', [[
    The Historic District is a charming area with cobblestone streets and preserved buildings from the city's past. It's a
    place where you can step back in time and explore the city's history, from ancient ruins to colonial architecture.
]])

createRoom(CentralHub, 'w', 'Residential District', [[
  
    The Residential District is a quiet area with beautiful homes and tree-lined streets. It's a peaceful neighborhood, with parks
    and playgrounds where families gather. The north road leads further into the residential area, while the south road takes you back
    to the lively city center.
  
]])


-- Forest Level 1
Forest1 = createRoom(CentralHub, 'n', 'Northen Gates', [[
    Behind city's Northen gates there is a path going along the city walls.
    All kind of bad people are known to lurk outside the city.
    North of here you see a dense forest.
]], { spawnMonstersLevel = 1, maxMonsters = 1 })


C = createRoom(Forest1, 'e', 'Eastern trail', [[
    The path along the city walls leads to the east and west.
]], { spawnMonstersLevel = 1, maxMonsters = 1 })

createRoom(C, 'e', 'Eastern Clif', [[
    The path among the rocks becomes narrower to the east and finally
    ends with a steep clif. It is nice and peaceful here.
 ]], { spawnMonstersLevel = 0, maxMonsters = 0 })


C = createRoom(Forest1, 'w', 'Western trail', [[
  The path among the rocks becomes narrower to the west.
  A lot of torn bags and broken weapons are scattered along the sides.
]], { spawnMonstersLevel = 1, maxMonsters = 1 })

C = createRoom(C, 'w', 'Western trail', [[
    At the end of the path to the west there is sort of some gates made
    of the rocks with a cows skull on top of it. Smoke is coming from the other side.
]], { spawnMonstersLevel = 1, maxMonsters = 2 })


createRoom(C, 'w', 'Western trail ghetto', [[
    This place has a bad reputation since a lot of shady characters 
    both from the forest and the city gather here to split their loot. 
]], { spawnMonstersLevel = 1, maxMonsters = 4 })

-- Level 2
Forest2 = createRoom(Forest1, 'n', 'Forest', [[
    You are in the Forest. You see way to the north, where forest seems to become darker.
    Remains of the ancient road lead both east and west.
]], { spawnMonstersLevel = 2, maxMonsters = 1 })

C = createRoom(Forest2, 'e', 'Forest', [[
    The path among the trees becomes narrower to the east. You hear sounds.
]], { spawnMonstersLevel = 2, maxMonsters = 2 })

createRoom(C, 'e', 'Forest', [[
    Huge clif blocks the way to the east here.
]], { spawnMonstersLevel = 2, maxMonsters = 3 })

C = createRoom(Forest2, 'w', 'Forest', [[
    The path among the trees becomes narrower to the west. You hear voices.
]], { spawnMonstersLevel = 2, maxMonsters = 2 })

C = createRoom(C, 'w', 'Forest', [[
    The path among the trees becomes narrower to the west and soon vanishes.
    Going further would be a bad idea.
]], { spawnMonstersLevel = 2, maxMonsters = 3 })

-- Level 3
Forest3 = createRoom(Forest2, 'n', 'Dense Forest', [[
    The forest thickens even more as you proceed north. The light barely penetrates the canopy.
    The air feels cooler and you sense movement around you. Paths to the east and west are less visible now.
]], { spawnMonstersLevel = 3, maxMonsters = 1 })

C = createRoom(Forest3, 'e', 'Shadowed Grove', [[
    The trees form an almost complete canopy here, casting deep shadows. You hear the rustling of leaves and distant whispers.
]], { spawnMonstersLevel = 3, maxMonsters = 2 })

createRoom(C, 'e', 'Whispering Cliffs', [[
    The path leads to the edge of steep cliffs. The wind carries faint whispers from below.
]], { spawnMonstersLevel = 3, maxMonsters = 3 })

C = createRoom(Forest3, 'w', 'Gloomy Thicket', [[
    The forest to the west is dense and gloomy. The trees seem to close in around you.
]], { spawnMonstersLevel = 3, maxMonsters = 2 })

createRoom(C, 'w', 'Dead End Clearing', [[
    The path ends abruptly in a small clearing surrounded by towering trees. The atmosphere is eerily quiet.
]], { spawnMonstersLevel = 3, maxMonsters = 1 })

-- Level 4
Forest4 = createRoom(Forest3, 'n', 'Twilight Woods', [[
    The forest here is bathed in perpetual twilight. Strange glowing plants illuminate the path. The air feels heavy with magic.
]], { spawnMonstersLevel = 4, maxMonsters = 1 })

C = createRoom(Forest4, 'e', 'Glowing Hollow', [[
    The trees here have bioluminescent bark, casting an eerie glow. The path narrows as it winds through the glowing foliage.
]], { spawnMonstersLevel = 4, maxMonsters = 2 })

createRoom(C, 'e', 'Luminous Gorge', [[
    The path ends at a gorge filled with glowing crystals. The light from the crystals flickers, casting strange shadows.
]], { spawnMonstersLevel = 4, maxMonsters = 3 })

C = createRoom(Forest4, 'w', 'Mystic Copse', [[
    The forest to the west is filled with strange, twisted trees. The air hums with an unsettling energy.
]], { spawnMonstersLevel = 4, maxMonsters = 2 })

createRoom(C, 'w', 'Enchanted Clearing', [[
    The path opens up into a clearing surrounded by trees with glowing runes. The air is thick with enchantment.
]], { spawnMonstersLevel = 4, maxMonsters = 3 })

-- Level 5
Forest5 = createRoom(Forest4, 'n', 'Enchanted Forest', [[
    The forest here feels alive with magic. The trees seem to whisper secrets, and the ground is covered with strange, glowing moss.
]], { spawnMonstersLevel = 5, maxMonsters = 1 })

C = createRoom(Forest5, 'e', 'Faerie Glade', [[
    A serene glade filled with faerie lights. The air is sweet with the scent of unknown flowers. Paths lead in all directions.
]], { spawnMonstersLevel = 5, maxMonsters = 2 })

createRoom(C, 'e', 'Fey Stream', [[
    A crystal-clear stream winds through the forest, its waters glowing with a magical light. The path ends at the stream’s edge.
]], { spawnMonstersLevel = 5, maxMonsters = 3 })

C = createRoom(Forest5, 'w', 'Witchs Grove', [[
    The trees here are gnarled and ancient. You feel as if you're being watched. Strange symbols are carved into the bark.
]], { spawnMonstersLevel = 5, maxMonsters = 2 })

createRoom(C, 'w', 'Dark Hollow', [[
    A dark, foreboding hollow where the trees block out all light. The atmosphere is thick with dread.
]], { spawnMonstersLevel = 5, maxMonsters = 3 })

-- Level 6
Forest6 = createRoom(Forest5, 'n', 'Ancient Woods', [[
    The forest is ancient, with towering trees and thick underbrush. The silence is oppressive, broken only by distant roars.
]], { spawnMonstersLevel = 6, maxMonsters = 1 })

C = createRoom(Forest6, 'e', 'Forgotten Path', [[
    An old, overgrown path leads deeper into the forest. The air is filled with the scent of decay and old magic.
]], { spawnMonstersLevel = 6, maxMonsters = 2 })

createRoom(C, 'e', 'Cursed Ruins', [[
    The path ends at the ruins of an ancient structure, half-buried in the forest. The stones are covered in dark, glowing runes.
]], { spawnMonstersLevel = 6, maxMonsters = 3 })

C = createRoom(Forest6, 'w', 'Haunted Glade', [[
    The glade is filled with ghostly apparitions that flicker in and out of existence. The air is cold and filled with whispers.
]], { spawnMonstersLevel = 6, maxMonsters = 2 })

createRoom(C, 'w', 'Spectral Clearing', [[
    A clearing surrounded by ghostly figures. The atmosphere is eerie, and you feel a chill down your spine.
]], { spawnMonstersLevel = 6, maxMonsters = 3 })

-- Level 7
Forest7 = createRoom(Forest6, 'n', 'Dark Enclave', [[
    The forest grows darker and more menacing. The trees seem to close in, and the shadows move with a life of their own.
]], { spawnMonstersLevel = 7, maxMonsters = 1 })

C = createRoom(Forest7, 'e', 'Shaded Path', [[
    The path is shrouded in darkness, with only occasional beams of light piercing the canopy. The air is thick with tension.
]], { spawnMonstersLevel = 7, maxMonsters = 2 })

createRoom(C, 'e', 'Eclipse Clearing', [[
    A clearing where the sun never seems to shine. The ground is cold and covered in a strange, black moss.
]], { spawnMonstersLevel = 7, maxMonsters = 3 })

C = createRoom(Forest7, 'w', 'Forsaken Woods', [[
    The forest here is desolate and empty, with dead trees and no signs of life. The silence is deafening.
]], { spawnMonstersLevel = 7, maxMonsters = 2 })

createRoom(C, 'w', 'Abandoned Grove', [[
    A grove filled with the remains of old campfires and broken weapons. The air is thick with the scent of battle and despair.
]], { spawnMonstersLevel = 7, maxMonsters = 3 })

-- Level 8
Forest8 = createRoom(Forest7, 'n', 'Nightmare Forest', [[
    The forest here is a twisted nightmare. The trees are gnarled and twisted, and the shadows seem to follow you.
]], { spawnMonstersLevel = 8, maxMonsters = 1 })

C = createRoom(Forest8, 'e', 'Horror Path', [[
    The path is lined with strange, unsettling statues. The air is filled with a sense of dread.
]], { spawnMonstersLevel = 8, maxMonsters = 2 })

createRoom(C, 'e', 'Terror Clearing', [[
    A clearing filled with the remains of those who came before. The air is thick with the scent of decay and fear.
]], { spawnMonstersLevel = 8, maxMonsters = 3 })

C = createRoom(Forest8, 'w', 'Despair Woods', [[
    The woods are filled with an overwhelming sense of despair. The trees seem to weep, and the ground is covered in blackened leaves.
]], { spawnMonstersLevel = 8, maxMonsters = 2 })

createRoom(C, 'w', 'Wailing Hollow', [[
    A hollow where the trees scream in the wind. The sound is unnerving, and you feel a deep sense of unease.
]], { spawnMonstersLevel = 8, maxMonsters = 3 })

-- Level 9
Forest9 = createRoom(Forest8, 'n', 'Doom Forest', [[
    The forest is thick with dark energy. The trees are blackened, and the ground is covered in ashes.
]], { spawnMonstersLevel = 9, maxMonsters = 1 })

C = createRoom(Forest9, 'e', 'Dread Path', [[
    The path is lined with skeletal remains. The air is cold, and you can see your breath.
]], { spawnMonstersLevel = 9, maxMonsters = 2 })

createRoom(C, 'e', 'Fearful Clearing', [[
    A clearing where the ground is littered with bones. The air is thick with the scent of death.
]], { spawnMonstersLevel = 9, maxMonsters = 3 })

C = createRoom(Forest9, 'w', 'Hopeless Woods', [[
    The woods are filled with a sense of hopelessness. The trees are twisted and gnarled, and the ground is covered in dead leaves.
]], { spawnMonstersLevel = 9, maxMonsters = 2 })

createRoom(C, 'w', 'Desolate Hollow', [[
    A hollow where the ground is barren and the trees are dead. The air is filled with a sense of emptiness.
]], { spawnMonstersLevel = 9, maxMonsters = 3 })

-- Level 10
Forest10 = createRoom(Forest9, 'n', 'Infernal Forest', [[
    The forest here is hellish. The trees are charred, and the ground is scorched. The air is filled with the scent of sulfur.
]], { spawnMonstersLevel = 10, maxMonsters = 1 })

C = createRoom(Forest10, 'e', 'Burning Path', [[
    The path is lined with burning trees. The heat is intense, and the air is filled with smoke.
]], { spawnMonstersLevel = 10, maxMonsters = 2 })

createRoom(C, 'e', 'Flaming Clearing', [[
    A clearing where the ground is on fire. The heat is unbearable, and you can feel the flames licking at your skin.
]], { spawnMonstersLevel = 10, maxMonsters = 3 })

C = createRoom(Forest10, 'w', 'Ashen Woods', [[
    The woods are filled with ash. The trees are blackened, and the ground is covered in a thick layer of ash.
]], { spawnMonstersLevel = 10, maxMonsters = 2 })

createRoom(C, 'w', 'Charred Hollow', [[
    A hollow where the ground is scorched and the trees are charred. The air is filled with the scent of burning wood.
]], { spawnMonstersLevel = 10, maxMonsters = 3 })

-- Level 11
Forest11 = createRoom(Forest10, 'n', 'Hellfire Forest', [[
    The forest is ablaze with hellfire. The trees are burning, and the ground is covered in flames. The heat is unbearable.
]], { spawnMonstersLevel = 11, maxMonsters = 1 })

C = createRoom(Forest11, 'e', 'Blazing Path', [[
    The path is engulfed in flames. The heat is intense, and the air is filled with smoke and ash.
]], { spawnMonstersLevel = 11, maxMonsters = 2 })

createRoom(C, 'e', 'Inferno Clearing', [[
    A clearing where the ground is consumed by flames. The heat is overwhelming, and the air is thick with smoke.
]], { spawnMonstersLevel = 11, maxMonsters = 3 })
