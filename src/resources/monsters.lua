monster_chances = {
    orc = 50,
    goblin = game.map.from_dungeon_level({{2, 25}, {4, 10}, {6, 0}}),
    kobold = game.map.from_dungeon_level({{1, 15}, {3, 30}, {5, 0}}),
    giant_rat = game.map.from_dungeon_level({{2, 25}, {4, 15}, {6, 0}}),
    vampire = game.map.from_dungeon_level({{9, 1}}),
    troll = game.map.from_dungeon_level({{3, 15}, {5, 30}, {7, 60}}),
    ogre = game.map.from_dungeon_level({{4, 10}, {6, 20}}),
}

monster_factory = {
    orc = function(x, y)
                local fighter_component = Fighter(20, 0, 2, 35, monster_death)
                local ai_component = BasicMonster()
                return GameObject(x, y, "o", "Orc", colors.green, true, fighter_component, ai_component)
    end,
    goblin = function(x, y)
                local fighter_component = Fighter(10, 1, 2, 25, monster_death)
                local ai_component = BasicMonster()
                return GameObject(x, y, "g", "Goblin", colors.dark_green, true, fighter_component, ai_component)
    end,

    kobold = function(x, y)
                local fighter_component = Fighter(15, 1, 2, 25, monster_death)
                local ai_component = BasicMonster()
                return GameObject(x, y, "k", "Kobold", colors.light_orange, true, fighter_component, ai_component)
    end,    
    giant_rat = function(x, y)
                local fighter_component = Fighter(25, 2, 4, 40, monster_death)
                local ai_component = BasicMonster()
                return GameObject(x, y, "R", "Giant Rat", colors.dark_blue, true, fighter_component, ai_component)
    end,        
    vampire = function(x, y)
                local fighter_component = Fighter(1, 1, 1, 500, monster_death)
                local ai_component = BasicMonster()
                local monster = GameObject(x, y, "w", "Vampire", colors.white, true, fighter_component, ai_component)
                add_invocation(monster, 999999, invoke_vampirism)
                return monster
    end,        
    troll = function(x, y)
                local fighter_component = Fighter(40, 2, 6, 60, monster_death)
                local ai_component = BasicMonster()
                return GameObject(x, y, "T", "Troll", colors.dark_green, true, fighter_component, ai_component)
    end,        
    ogre = function(x, y)
                local fighter_component = Fighter(25, 0, 8, 70, monster_death)
                local ai_component = BasicMonster()
                return GameObject(x, y, "O", "Ogre", colors.grey_7, true, fighter_component, ai_component)
    end
}

return {chances=monster_chances, factory=monster_factory}