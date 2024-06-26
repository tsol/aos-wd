
Globals = {
  MaxMint = 1000000000,
  MonsterExpGain = 25,
  GoldOnKillXfer = 0.65,
  HideInactivePeopleTimeout = 1000000,
  TransferInactivePeopleTimeout = 3 * 60 * 60 * 1000,-- 3 hours
  TransferInactivePeopleTo = "/999-1000-1000",
}

Houses = {
  House = "🏠",
  Garden = "🏡",
  Houses = "🏘️",
  Derelict = "🏚️",
  Construction = "🏗️",
  Office = "🏢",
  JapanesePostOffice = "🏣",
  PostOffice = "🏤",
  Hospital = "🏥",
  Bank = "🏦",
  Hotel = "🏨",
  LoveHotel = "🏩",
  ConvenienceStore = "🏪",
  School = "🏫",
  DepartmentStore = "🏬",
  Factory = "🏭",
  JapaneseCastle = "🏯",
  Castle = "🏰",

  Fountain = "⛲",
  Stadium = "🏟️",
}

Icons = {
  WhiteMediumStar = "⭐",
  GlowingStar = "🌟",
  Sparkles = "✨",
  Cyclone = "🌀",
  Foggy = "🌁",
  Rainbow = "🌈",
  ClosedUmbrella = "🌂",
  HighVoltage = "⚡",
  Snowflake = "❄️",
  Fire = "🔥",
  Droplet = "💧",
  WindFace = "🌬️",
  Pill = "💊",
  Pharmacy = "⚕️",
  Trophy = "🏆",
}

Nature = {
  Tree = "🌳",
  DeciduousTree = "🌲",
  PalmTree = "🌴",
  Cactus = "🌵",
  EvergreenTree = "🌿",
  Herb = "🌱",
  Shamrock = "☘️",
  FourLeafClover = "🍀",
  FallenLeaf = "🍂",
  LeafFlutteringWind = "🍃",
  SheafOfRice = "🌾",
  Hibiscus = "🌺",
  Sunflower = "🌻",
  Blossom = "🌼",
  Tulip = "🌷",
  Rose = "🌹",
}

Fruits = {
  Apple = '🍎',
  Banana = '🍌',
  Cherry = '🍒',
  Mango = '🥭',
  Watermelon = '🍉',
  Pineapple = '🍍',
  Strawberry = '🍓',
  Kiwi = '🥝',
  Grapes = '🍇',
  Orange = '🍊',
  Peach = '🍑',
  Pear = '🍐',
  Plum = '🍑',
  Lemon = '🍋',
  Lime = '🍈',
  Coconut = '🥥',
  Pomegranate = '🥭',
  Blueberry = '🫐',
  Raspberry = '🍇',
  Blackberry = '🫐',
  Cranberry = '🍒',
  Gooseberry = '🍇',
  Apricot = '🍑',
  Papaya = '🥭'
}


Medival = {
  Knight = "⚔️",
  Dagger = "🗡️",
  Bow = "🏹",
  Shield = "🛡️",
  Horse = "🏇",
  Axe = "🪓",
  Mage = "🧙‍♂️",
  WomanMage = "🧙‍♀️",
  Crown = "👑",
}


Terrain = {
  city = Houses.Castle,
  forest = Nature.Tree,
  hospital = Icons.Pharmacy,
}

ShopItemTypes = {
  armor = {
    icon = Medival.Shield,
    name = "Armor",
    fields = { { field = "defence", title = "Defence" } },
    none = { name = "Nothing", price = 0, defence = 0 }
  },
  weapon = {
    icon = Medival.Dagger,
    name = "Weapon",
    fields = { { field = "str", title = "Strength" } },
    none = { name = "Fists", price = 0, str = 0 }
  }
}

ShopItems = {
  { level = 0,  type = 'armor',  name = "Nothing",             price = 0,         defence = 0 },
  { level = 1,  type = 'armor',  name = "Travelers Robe",      price = 200,       defence = 1 },
  { level = 2,  type = 'armor',  name = "Reinforced Coat",     price = 1000,      defence = 3 },
  { level = 3,  type = 'armor',  name = "Leather Vest",        price = 3000,      defence = 10 },
  { level = 4,  type = 'armor',  name = "Bronze Plate",        price = 10000,     defence = 15 },
  { level = 5,  type = 'armor',  name = "Iron Guard",          price = 30000,     defence = 25 },
  { level = 6,  type = 'armor',  name = "Shadow Cloak",        price = 100000,    defence = 35 },
  { level = 7,  type = 'armor',  name = "Armor of Knight",     price = 150000,    defence = 50 },
  { level = 8,  type = 'armor',  name = "Silver Mail",         price = 200000,    defence = 75 },
  { level = 9,  type = 'armor',  name = "Diamond Plate",       price = 400000,    defence = 100 },
  { level = 10, type = 'armor',  name = "Full Plate Armor",    price = 1000000,   defence = 150 },
  { level = 11, type = 'armor',  name = "Blood Ward",          price = 4000000,   defence = 225 },
  { level = 12, type = 'armor',  name = "Arcane Shield",       price = 10000000,  defence = 300 },
  { level = 13, type = 'armor',  name = "Mythril Plate",       price = 40000000,  defence = 400 },
  { level = 14, type = 'armor',  name = "Golden Aegis",        price = 100000000, defence = 600 },
  { level = 15, type = 'armor',  name = "Mythical Armor",      price = 400000000, defence = 1000 },

  { level = 0,  type = 'weapon', name = "Fists",               price = 0,         str = 0 },
  { level = 1,  type = 'weapon', name = "Club",                price = 200,       str = 5 },
  { level = 2,  type = 'weapon', name = "Knife",               price = 1000,      str = 10 },
  { level = 3,  type = 'weapon', name = "Short Blade",         price = 3000,      str = 20 },
  { level = 4,  type = 'weapon', name = "Long Blade",          price = 10000,     str = 30 },
  { level = 5,  type = 'weapon', name = "Battle Axe",          price = 30000,     str = 40 },
  { level = 6,  type = 'weapon', name = "Skull Crusher",       price = 100000,    str = 60 },
  { level = 7,  type = 'weapon', name = "Dual Blades",         price = 150000,    str = 80 },
  { level = 8,  type = 'weapon', name = "War Axe",             price = 200000,    str = 120 },
  { level = 9,  type = 'weapon', name = "Blade of Hero",       price = 400000,    str = 180 },
  { level = 10, type = 'weapon', name = "Mace of Destruction", price = 1000000,   str = 250 },
  { level = 11, type = 'weapon', name = "Spear of Seth",       price = 4000000,   str = 350 },
  { level = 12, type = 'weapon', name = "Crimson Shard",       price = 10000000,  str = 500 },
  { level = 13, type = 'weapon', name = "Fang of Shadows",     price = 40000000,  str = 800 },
  { level = 14, type = 'weapon', name = "Blood Blade",         price = 100000000, str = 1200 },
  { level = 15, type = 'weapon', name = "Dooms Blade",         price = 400000000, str = 1800 }
}

Bosses = {
  { level = 1,  name = "Vitalkir",    exp = 100,      hp = 30,    str = 15,   weapon = "Ether Blade" },
  { level = 2,  name = "Szatosh",     exp = 400,      hp = 40,    str = 17,   weapon = "Thundering Axe" },
  { level = 3,  name = "Finton",      exp = 1000,     hp = 70,    str = 35,   weapon = "Storm's Edge" },
  { level = 4,  name = "Etzerik",     exp = 4000,     hp = 120,   str = 70,   weapon = "Dragon's Fang" },
  { level = 5,  name = "Sandtiger",   exp = 10000,    hp = 200,   str = 100,  weapon = "Serpent's Bite" },
  { level = 6,  name = "Szerc",       exp = 40000,    hp = 400,   str = 150,  weapon = "Moonlight Slicer" },
  { level = 7,  name = "Kurten",      exp = 100000,   hp = 600,   str = 250,  weapon = "Phoenix Blade" },
  { level = 8,  name = "Alan",        exp = 400000,   hp = 800,   str = 350,  weapon = "Starlight Staff" },
  { level = 9,  name = "Lorel",       exp = 1000000,  hp = 1200,  str = 500,  weapon = "Doombringer" },
  { level = 10, name = "Gandaalf",    exp = 4000000,  hp = 1800,  str = 800,  weapon = "Eternal Flame" },
  { level = 11, name = "Torquen",     exp = 10000000, hp = 2500,  str = 1200, weapon = "Soul Reaver" },
  { level = 12, name = "Master Yoga", exp = 24000000, hp = 3000, str = 1500, weapon = "Lightsabre" },

  { level = 13, name = "Kuklachev",   exp = 48000000, hp = 3700, str = 1900, weapon = "Furry whip" },
  { level = 14, name = "Kha-Thor",    exp = 99000000, hp = 4500, str = 2300, weapon = "Worthy Battlette" },
  { level = 15, name = "Azrael",      exp = 153000000, hp = 5000, str = 2500, weapon = "Scythe of Doom" }

}


FlirtSchema = {
  { charm = 1,  name = 'Wink',      success = '%s winks at %s and %s blushes.',              fail = '%s winks at %s and %s looks away.' },
  { charm = 2,  name = 'Smile',     success = '%s smiles at %s and %s smiles back.',         fail = '%s smiles at %s and %s looks away.' },
  { charm = 3,  name = 'Blow Kiss', success = '%s blows a kiss at %s and %s catches it.',    fail = '%s blows a kiss at %s and %s dodges it.' },
  { charm = 4,  name = 'Flirt',     success = '%s flirts with %s and %s flirts back.',       fail = '%s flirts with %s and %s looks away.' },
  { charm = 5,  name = 'Hug',       success = '%s hugs %s and %s hugs back.',                fail = '%s hugs %s and %s pushes away.' },
  { charm = 6,  name = 'Kiss',      success = '%s kisses %s and %s kisses back.',            fail = '%s kisses %s and %s slaps.' },
  { charm = 7,  name = 'Make Out',  success = '%s makes out with %s and %s makes out back.', fail = '%s makes out with %s and %s slaps.' },
  { charm = 8,  name = 'Proposal',  success = '%s proposes to %s and %s accepts.',           fail = '%s proposes to %s and %s rejects.' },
  { charm = 9,  name = 'Marriage',  success = '%s marries %s and %s marries back.',          fail = '%s marries %s and %s leaves.' },
  { charm = 10, name = 'Divorce',   success = '%s divorces %s and %s divorces back.',        fail = '%s divorces %s and %s leaves.' },
}

Mobs = {
  { level = 1, terrain = "hospital", type = "good", gender = "she", unique = 1, name = "Lilly the nurse", str = 8, exp = 10, hp = 12, gold = 34, weapon = "Stethoscope" },
  { level = 1, terrain = "inn",    type = "good", gender = "she", unique = 1, name = "Sara the Barmaid", str = 6, exp = 8,  hp = 10, gold = 23, weapon = "Beer Mug" },
  { level = 1, terrain = "fountain", type = "good", gender = "he", unique = 1, name = "Seth the Bard",  str = 12, exp = 9,  hp = 11, gold = 27, weapon = "Lute" },
}

Monsters = {
  { level = 1,  name = "Large Mosquito",             str = 3,    exp = 2,        hp = 3,     gold = 46,      weapon = "Blood Sucker" },
  { level = 1,  name = "Large Rat",                  str = 3,    exp = 2,        hp = 4,     gold = 32,      weapon = "Sharp Teeth" },
  { level = 1,  name = "Rude boy",                   str = 4,    exp = 3,        hp = 7,     gold = 7,       weapon = "Cudgel" },
  { level = 1,  name = "Dumpster Racoon",            str = 4,    exp = 3,        hp = 4,     gold = 5,       weapon = "Clean paws" },
  { level = 1,  name = "Old Man",                    str = 5,    exp = 5,        hp = 13,    gold = 73,      weapon = "Cane" },
  { level = 1,  name = "Crazy Old Bitch",            str = 5,    exp = 5,        hp = 18,    gold = 20,      weapon = "Shoe" },
  { level = 1,  name = "Wild Dog",                   str = 5,    exp = 5,        hp = 8,     gold = 11,      weapon = "Slightly Tilted Head" },
  { level = 1,  name = "Homeless Dude",              str = 5,    exp = 4,        hp = 7,     gold = 8,       weapon = "Shopping cart" },
  { level = 1,  name = "Meth Addict",                str = 5,    exp = 8,        hp = 12,    gold = 0,       weapon = "Bad teeth" },
  { level = 1,  name = "A pimp",                     str = 5,    exp = 9,        hp = 14,    gold = 50,      weapon = "Pocket knife" },

  { level = 1,  name = "Small Thief",                str = 6,    exp = 5,        hp = 9,     gold = 56,      weapon = "Small Dagger" },
  { level = 1,  name = "Ugly Old Hag",               str = 6,    exp = 6,        hp = 9,     gold = 109,     weapon = "Garlic Breath" },
  { level = 1,  name = "Evil Wretch",                str = 7,    exp = 6,        hp = 12,    gold = 76,      weapon = "Finger Nail" },
  { level = 1,  name = "Small Bear",                 str = 9,    exp = 6,        hp = 7,     gold = 154,     weapon = "Claws" },
  { level = 1,  name = "Wild Boar",                  str = 10,   exp = 7,        hp = 9,     gold = 58,      weapon = "Sharp Tusks" },
  { level = 1,  name = "Drunken Sailor",             str = 11,   exp = 8,        hp = 11,    gold = 134,     weapon = "Broken Bottle" },
  { level = 1,  name = "Bran the Fighter",           str = 12,   exp = 10,       hp = 15,    gold = 234,     weapon = "Short Sword" },

  { level = 2,  name = "Fedrick the Limping Baboon", str = 8,    exp = 6,        hp = 23,    gold = 97,      weapon = "Scary Face" },
  { level = 2,  name = "Membrain Man",               str = 10,   exp = 11,       hp = 16,    gold = 190,     weapon = "Strange Ooze" },
  { level = 2,  name = "Bent River Dryad",           str = 12,   exp = 9,        hp = 16,    gold = 150,     weapon = "Pouring Waterfall" },
  { level = 2,  name = "Gath the Barbarian",         str = 12,   exp = 9,        hp = 13,    gold = 134,     weapon = "Huge Spiked Club" },
  { level = 2,  name = "Senile Senior Citizen",      str = 13,   exp = 13,       hp = 11,    gold = 270,     weapon = "Crazy Ravings" },
  { level = 2,  name = "Green Python",               str = 13,   exp = 6,        hp = 17,    gold = 80,      weapon = "Dripping Fangs" },
  { level = 2,  name = "Wild Man",                   str = 13,   exp = 8,        hp = 14,    gold = 134,     weapon = "Hands" },
  { level = 2,  name = "Evil Wood Nymph",            str = 15,   exp = 11,       hp = 10,    gold = 160,     weapon = "Flirtatios Behavior" },
  { level = 2,  name = "Huge Bald Man",              str = 19,   exp = 16,       hp = 19,    gold = 311,     weapon = "Glare From Forehead" },
  { level = 2,  name = "Brorandia the Viking",       str = 21,   exp = 20,       hp = 18,    gold = 330,     weapon = "Hugely Spiked Mace" },

  { level = 3,  name = "Purple Monchichi",           str = 14,   exp = 23,       hp = 29,    gold = 763,     weapon = "Continuous Whining" },
  { level = 3,  name = "Two Headed Rotweiler",       str = 18,   exp = 17,       hp = 32,    gold = 384,     weapon = "Twin Barking" },
  { level = 3,  name = "Red Neck",                   str = 19,   exp = 19,       hp = 16,    gold = 563,     weapon = "Awfull Country Slang" },
  { level = 3,  name = "Lazy Bum",                   str = 19,   exp = 18,       hp = 29,    gold = 380,     weapon = "Unwashed Body Odor" },
  { level = 3,  name = "Headbanger of the West",     str = 23,   exp = 43,       hp = 27,    gold = 245,     weapon = "Ear Shattering Noises" },
  { level = 3,  name = "Muscled Midget",             str = 26,   exp = 32,       hp = 19,    gold = 870,     weapon = "Low Punch" },
  { level = 3,  name = "Bone",                       str = 27,   exp = 16,       hp = 11,    gold = 432,     weapon = "Terrible Smoke Smell" },
  { level = 3,  name = "Black Owl",                  str = 28,   exp = 26,       hp = 29,    gold = 711,     weapon = "Hooked Beak" },
  { level = 3,  name = "Morbid Walker",              str = 28,   exp = 9,        hp = 10,    gold = 764,     weapon = "Endless Walking" },
  { level = 3,  name = "Winged Demon of Death",      str = 42,   exp = 28,       hp = 23,    gold = 830,     weapon = "Red Glare" },

  { level = 4,  name = "Weak Orc",                   str = 27,   exp = 27,       hp = 32,    gold = 900,     weapon = "Spiked Club" },
  { level = 4,  name = "Death Jester",               str = 34,   exp = 29,       hp = 46,    gold = 1343,    weapon = "Horrible Jokes" },
  { level = 4,  name = "Short Goblin",               str = 34,   exp = 34,       hp = 45,    gold = 768,     weapon = "Short Sword" },
  { level = 4,  name = "Evil Hobbit",                str = 35,   exp = 46,       hp = 95,    gold = 1240,    weapon = "Smoking Pipe" },
  { level = 4,  name = "Death Dog",                  str = 36,   exp = 46,       hp = 52,    gold = 1150,    weapon = "Teeth" },
  { level = 4,  name = "Dark Elf",                   str = 43,   exp = 53,       hp = 57,    gold = 1070,    weapon = "Small bow" },
  { level = 4,  name = "Mud Man",                    str = 56,   exp = 63,       hp = 65,    gold = 870,     weapon = "Mud Balls" },
  { level = 4,  name = "Young Wizard",               str = 64,   exp = 75,       hp = 35,    gold = 1754,    weapon = "Weak Magic" },
  { level = 4,  name = "Huge Black Bear",            str = 67,   exp = 99,       hp = 48,    gold = 1765,    weapon = "Razor Claws" },

  { level = 5,  name = "Clancy, Son of Emperor Len", str = 52,   exp = 324,      hp = 324,   gold = 4764,    weapon = "Spiked Bull Whip" },
  { level = 5,  name = "George of the Jungle",       str = 56,   exp = 128,      hp = 43,    gold = 2230,    weapon = "Echoing Screams" },
  { level = 5,  name = "Jabba",                      str = 61,   exp = 137,      hp = 198,   gold = 2384,    weapon = "Whiplashing Tail" },
  { level = 5,  name = "Pandion Knight",             str = 64,   exp = 98,       hp = 59,    gold = 3100,    weapon = "Orkos Broadsword" },
  { level = 5,  name = "Black Alligator",            str = 65,   exp = 123,      hp = 65,    gold = 3245,    weapon = "Extra Sharp Teeth" },
  { level = 5,  name = "Trojan Warrior",             str = 73,   exp = 154,      hp = 87,    gold = 3432,    weapon = "Twin Swords" },
  { level = 5,  name = "Misfit the Ugly",            str = 75,   exp = 120,      hp = 89,    gold = 2563,    weapon = "Strange Ideas" },
  { level = 5,  name = "Bald Medusa",                str = 78,   exp = 256,      hp = 120,   gold = 4000,    weapon = "Glare Of Stone" },
  { level = 5,  name = "Black Sorcerer",             str = 86,   exp = 154,      hp = 25,    gold = 2838,    weapon = "Spell Of Lightning" },
  { level = 5,  name = "Silent Death",               str = 113,  exp = 230,      hp = 98,    gold = 4711,    weapon = "Pale Smoke" },

  { level = 6,  name = "Empty Armour",               str = 67,   exp = 432,      hp = 390,   gold = 6431,    weapon = "Cutting Wind" },
  { level = 6,  name = "Wild Stallion",              str = 78,   exp = 532,      hp = 245,   gold = 4643,    weapon = "Hoofs" },
  { level = 6,  name = "Raging Lion",                str = 98,   exp = 365,      hp = 274,   gold = 3643,    weapon = "Teeth And Claws" },
  { level = 6,  name = "Screaming Zombie",           str = 98,   exp = 354,      hp = 286,   gold = 5322,    weapon = "Gaping Mouth Full Of Teeth" },
  { level = 6,  name = "Iron Warrior",               str = 100,  exp = 364,      hp = 253,   gold = 6542,    weapon = "3 Iron" },
  { level = 6,  name = "Satans Helper",              str = 112,  exp = 453,      hp = 165,   gold = 7543,    weapon = "Pack Of Lies" },
  { level = 6,  name = "Huge Stone Warrior",         str = 112,  exp = 543,      hp = 232,   gold = 4942,    weapon = "Rock Fist" },
  { level = 6,  name = "Black Soul",                 str = 112,  exp = 432,      hp = 432,   gold = 5865,    weapon = "Black Candle" },
  { level = 6,  name = "Belar",                      str = 120,  exp = 565,      hp = 352,   gold = 9432,    weapon = "Fists Of Rage" },

  { level = 7,  name = "Fallen Angel",               str = 154,  exp = 483,      hp = 654,   gold = 12339,   weapon = "Throwing Halos" },
  { level = 7,  name = "Goblin Pygmy",               str = 165,  exp = 754,      hp = 576,   gold = 13252,   weapon = "Death Squeeze" },
  { level = 7,  name = "Angry Liontaur",             str = 187,  exp = 753,      hp = 495,   gold = 13259,   weapon = "Arms And Teeth" },
  { level = 7,  name = "Wicked Wombat",              str = 198,  exp = 786,      hp = 464,   gold = 13283,   weapon = "The Dark Wombats Curse" },
  { level = 7,  name = "Massive Dinosaur",           str = 200,  exp = 1204,     hp = 986,   gold = 16753,   weapon = "Gaping Jaws" },
  { level = 7,  name = "Emporer Len",                str = 210,  exp = 764,      hp = 432,   gold = 12043,   weapon = "Lightning Bull Whip" },
  { level = 7,  name = "Night Hawk",                 str = 220,  exp = 686,      hp = 675,   gold = 10433,   weapon = "Blood Red Talons" },
  { level = 7,  name = "Swiss Butcher",              str = 230,  exp = 532,      hp = 453,   gold = 8363,    weapon = "Meat Cleaver" },
  { level = 7,  name = "Goliath",                    str = 243,  exp = 898,      hp = 343,   gold = 14322,   weapon = "Six Fingered Fist" },

  { level = 8,  name = "Baby Dragon",                str = 176,  exp = 3675,     hp = 2322,  gold = 25863,   weapon = "Dragon Smoke" },
  { level = 8,  name = "Wans Beast",                 str = 193,  exp = 2432,     hp = 1243,  gold = 17141,   weapon = "Crushing Embrace" },
  { level = 8,  name = "Werewolf",                   str = 230,  exp = 3853,     hp = 543,   gold = 19474,   weapon = "Fangs" },
  { level = 8,  name = "Lord Mathese",               str = 245,  exp = 2422,     hp = 875,   gold = 24935,   weapon = "Fencing Sword" },
  { level = 8,  name = "Fire Ork",                   str = 267,  exp = 3942,     hp = 674,   gold = 24933,   weapon = "FireBall" },
  { level = 8,  name = "Death Knight",               str = 287,  exp = 4382,     hp = 674,   gold = 21923,   weapon = "Huge Silver Sword" },
  { level = 8,  name = "Screeching Witch",           str = 300,  exp = 2283,     hp = 674,   gold = 19753,   weapon = "Spell Of Ice" },
  { level = 8,  name = "Rundorig",                   str = 330,  exp = 2748,     hp = 675,   gold = 17853,   weapon = "Poison Claws" },
  { level = 8,  name = "King Vidion",                str = 400,  exp = 6764,     hp = 1243,  gold = 28575,   weapon = "Long Sword Of Death" },

  { level = 9,  name = "Hemo-glob",                  str = 212,  exp = 4432,     hp = 1232,  gold = 27853,   weapon = "Weak Insults" },
  { level = 9,  name = "Ernest Brown",               str = 432,  exp = 9754,     hp = 2488,  gold = 34844,   weapon = "Knee" },
  { level = 9,  name = "Pink Elephant",              str = 438,  exp = 7843,     hp = 1232,  gold = 33844,   weapon = "Stomping" },
  { level = 9,  name = "FrankenMoose",               str = 455,  exp = 5433,     hp = 1221,  gold = 31221,   weapon = "Butting Head" },
  { level = 9,  name = "Gwendolens' Nightmare",      str = 490,  exp = 8232,     hp = 764,   gold = 35846,   weapon = "Dreams" },
  { level = 9,  name = "Apeman",                     str = 498,  exp = 7202,     hp = 1283,  gold = 38955,   weapon = "Hairy Hands" },
  { level = 9,  name = "Rentakis' Pet",              str = 556,  exp = 9854,     hp = 987,   gold = 37584,   weapon = "Gaping Maw" },
  { level = 9,  name = "Scallian Rap",               str = 601,  exp = 6784,     hp = 788,   gold = 22430,   weapon = "Way Of Hurting People" },
  { level = 9,  name = "Earth Shaker",               str = 767,  exp = 7432,     hp = 985,   gold = 37565,   weapon = "Earthquake" },

  { level = 10, name = "Black Sorcerer",             str = 86,   exp = 187,      hp = 25,    gold = 2838,    weapon = "Spell Of Lightning" },
  { level = 10, name = "Adult Gold Dragon",          str = 565,  exp = 15364,    hp = 3222,  gold = 56444,   weapon = "Dragon Fire" },
  { level = 10, name = "Tiger of the Deep Jungle",   str = 587,  exp = 9766,     hp = 3101,  gold = 43933,   weapon = "Eye Of The Tiger" },
  { level = 10, name = "Brand the Wanderer",         str = 643,  exp = 13744,    hp = 2788,  gold = 38755,   weapon = "Fighting Quarter Staff" },
  { level = 10, name = "Slock",                      str = 744,  exp = 14333,    hp = 1675,  gold = 56444,   weapon = "Swamp Slime" },
  { level = 10, name = "Death Dealer",               str = 765,  exp = 13877,    hp = 1764,  gold = 47333,   weapon = "Stare Of Paralization" },
  { level = 10, name = "Floating Evil Eye",          str = 776,  exp = 13455,    hp = 2232,  gold = 43233,   weapon = "Evil Stare" },
  { level = 10, name = "Toraks Son, Korak",          str = 921,  exp = 13877,    hp = 1384,  gold = 46575,   weapon = "Sword Of Lightning" },
  { level = 10, name = "Sweet Looking Little Girl",  str = 989,  exp = 14534,    hp = 1232,  gold = 52322,   weapon = "Demon Strike" },

  { level = 11, name = "Vegetable Creature",         str = 111,  exp = 2187,     hp = 172,   gold = 4838,    weapon = "Pickled Cabbage" },
  { level = 11, name = "Ables' Creature",            str = 985,  exp = 28222,    hp = 2455,  gold = 176775,  weapon = "Bear Hug" },
  { level = 11, name = "Gorma the Leper",            str = 1132, exp = 26333,    hp = 2766,  gold = 168774,  weapon = "Contagous Desease" },
  { level = 11, name = "Shogun Warrior",             str = 1143, exp = 26555,    hp = 3878,  gold = 165433,  weapon = "Japanese Nortaki" },
  { level = 11, name = "Madman",                     str = 1265, exp = 25665,    hp = 1764,  gold = 149564,  weapon = "Chant Of Insanity" },
  { level = 11, name = "White Bear of Lore",         str = 1344, exp = 16775,    hp = 1875,  gold = 65544,   weapon = "Snow Of Death" },
  { level = 11, name = "Sheena the Shapechanger",    str = 1463, exp = 26655,    hp = 1898,  gold = 165755,  weapon = "Deadly Illusions" },
  { level = 11, name = "Mountain",                   str = 1544, exp = 38774,    hp = 1284,  gold = 186454,  weapon = "Landslide" },
  { level = 11, name = "ShadowStormWarrior",         str = 1655, exp = 26181,    hp = 2767,  gold = 162445,  weapon = "Mystical Storm" },
  { level = 11, name = "Cyclops Warrior",            str = 1744, exp = 49299,    hp = 2899,  gold = 204000,  weapon = "Fire Eye" },

  { level = 12, name = "Kal Torak",                  str = 876,  exp = 94664,    hp = 6666,  gold = 447774,  weapon = "Cthrek Goru" },
  { level = 12, name = "Humongous Black Wyre",       str = 1166, exp = 76000,    hp = 3453,  gold = 653834,  weapon = "Death Talons" },
  { level = 12, name = "Black Warlock",              str = 1366, exp = 58989,    hp = 2767,  gold = 168483,  weapon = "Satanic Choruses" },
  { level = 12, name = "The Wizard of Darkness",     str = 1497, exp = 39878,    hp = 1383,  gold = 224964,  weapon = "Chant Of Insanity" },
  { level = 12, name = "The Mighty Shadow",          str = 1633, exp = 51655,    hp = 2332,  gold = 176333,  weapon = "Shadow Axe" },
  { level = 12, name = "Black Unicorn",              str = 1899, exp = 41738,    hp = 1587,  gold = 336693,  weapon = "Shredding Horn" },
  { level = 12, name = "Corinthian Giant",           str = 2400, exp = 60333,    hp = 2544,  gold = 336643,  weapon = "De-rooted Tree" },
  { level = 12, name = "Mutated Black Widow",        str = 2575, exp = 98993,    hp = 1276,  gold = 434370,  weapon = "Venom Bite" },

  { level = 13, name = "Infernal Beast",               str = 2789, exp = 129332,    hp = 5421,  gold = 557444,  weapon = "Flame Breath" },
  { level = 13, name = "Nightmare Phantom",            str = 2955, exp = 137655,    hp = 4722,  gold = 483777,  weapon = "Ethereal Claws" },
  { level = 13, name = "Dread Sorcerer",               str = 3100, exp = 142876,    hp = 3985,  gold = 502333,  weapon = "Dark Incantation" },
  { level = 13, name = "Hellhound",                    str = 3222, exp = 149999,    hp = 4378,  gold = 523899,  weapon = "Inferno Bite" },
  { level = 13, name = "Void Assassin",                str = 3450, exp = 158787,    hp = 4873,  gold = 598774,  weapon = "Shadow Daggers" },
  { level = 13, name = "Gargantuan Troll",             str = 3680, exp = 165432,    hp = 5264,  gold = 645544,  weapon = "Club Smash" },
  { level = 13, name = "Vampire Lord",                 str = 3890, exp = 172333,    hp = 4855,  gold = 583455,  weapon = "Blood Drain" },

  { level = 14, name = "Demonic Overlord",             str = 4125, exp = 189456,    hp = 6222,  gold = 698877,  weapon = "Hellfire Whip" },
  { level = 14, name = "Ancient Dragon",               str = 4300, exp = 198765,    hp = 6589,  gold = 723999,  weapon = "Dragon Flame" },
  { level = 14, name = "Nether Wraith",                str = 4555, exp = 205444,    hp = 5844,  gold = 669833,  weapon = "Soul Siphon" },
  { level = 14, name = "Celestial Warrior",            str = 4777, exp = 218777,    hp = 6722,  gold = 788444,  weapon = "Heavenly Sword" },
  { level = 14, name = "Lich King",                    str = 4950, exp = 229332,    hp = 5938,  gold = 745111,  weapon = "Death Staff" },
  { level = 14, name = "Thunder Giant",                str = 5200, exp = 239876,    hp = 7111,  gold = 799333,  weapon = "Lightning Hammer" },
  { level = 14, name = "Spectral Reaper",              str = 5455, exp = 249777,    hp = 7333,  gold = 824999,  weapon = "Ethereal Scythe" },

  { level = 15, name = "The White Rabbit",           str = 6000, exp = 10000000, hp = 15000, gold = 1000000, weapon = "Bunny tail" }

}

local function normalizeGold(entity)
  local res = ''
  for i, e in ipairs(entity) do
    local field = 'price'
    if e.gold then
      field = 'gold'
    end
    local newValue = math.floor(e[field] / (e.level > 0 and e.level or 1))
    res = res .. string.format("Level: %d, Name: %s, Gold: %d -> %d\n", e.level, e.name, e[field], newValue)
    e[field] = newValue
  end
  return res
end

function _monstersExpNormalize()
  for i, m in ipairs(Monsters) do
    m.exp = m.exp * 2
  end
end

function _norm()
  local res = ''
  res = res .. normalizeGold(Monsters)
  res = res .. normalizeGold(Mobs)
  res = res .. normalizeGold(ShopItems)
  _monstersExpNormalize()
  return res
end

_norm();



function _showMonsters()
  local res = ''
  -- by each level count avarage parameters for monsters
  -- hp, str, exp, gold

  local levels = {}
  for i, m in ipairs(Monsters) do
    if not levels[m.level] then
      levels[m.level] = { hp = 0, str = 0, exp = 0, gold = 0, count = 0 }
    end
    levels[m.level].hp = levels[m.level].hp + m.hp
    levels[m.level].str = levels[m.level].str + m.str
    levels[m.level].exp = levels[m.level].exp + m.exp
    levels[m.level].gold = levels[m.level].gold + m.gold
    levels[m.level].count = levels[m.level].count + 1

    -- get corresponding boss. boss exp is level player needs to reach to level up
    local bossForLevel = nil
    for i, b in ipairs(Bosses) do
      if b.level == m.level then
        bossForLevel = b
        break
      end
    end

    levels[m.level].boss = bossForLevel

    -- find corresponding shop items, calculate medium price for item at the level

    local shopItemsForLevel = {}
    for i, s in ipairs(ShopItems) do
      if s.level == m.level then
        table.insert(shopItemsForLevel, s)
      end
    end

    local sum = 0
    for i, s in ipairs(shopItemsForLevel) do
      sum = sum + s.price
    end

    local avgPrice = math.floor(sum / #shopItemsForLevel)

    levels[m.level].avgShopPrice = avgPrice

  end

  for i, l in pairs(levels) do
    local needExp = (l.boss and l.boss.exp) or 0
    local avgExp = math.floor(l.exp / l.count)
    local killsToLevel = math.floor(needExp / avgExp)

    -- amount of kills to buy item
    local avgGoldPerMonster = math.floor(l.gold / l.count)
    local killsForItem = math.floor(l.avgShopPrice / avgGoldPerMonster)

    res = res .. string.format("Level: %d, HP: %d, STR: %d, EXP: %d, GOLD: %d, COUNT: %d, kills: %d, item_price: %d, kills4item: %d\n",
      i,
      math.floor(l.hp / l.count),
      math.floor(l.str / l.count),
      avgExp,
      avgGoldPerMonster,
      l.count,
      killsToLevel,
      l.avgShopPrice,
      killsForItem
    )
  end

  return res
end



