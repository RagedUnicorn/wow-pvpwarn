--[[
  PVPWarn - A WoW 1.12.1 Addon to alert the player of pvp events
  Copyright (C) 2018 Michael Wiesendanger <michael.wiesendanger@gmail.com>

  This file is part of PVPWarn.

  PVPWarn is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  PVPWarn is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with PVPWarn.  If not, see <http://www.gnu.org/licenses/>.
]]--

local mod = pvpw
local me = {}
mod.parser = me

me.tag = "Parser"

--[[
  CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS
  [source] [keyword] [spell]

  examples:
    $player$ gains Berserker Rage.
    $player$ gains Death Wish.
    $player$ gains Recklessness.
    $player$ gains Defensive Stance.
    $player$ gains Battle Stance.
    $player$ gains Berserker Stance.
    $player$ gains Shield Wall.
    $player$ gains Elune's Grace.
]]--
local SPELL_PERIODIC_HOSTILE_PLAYER_BUFFS1 = "^(%a+)%s(gains)%s([%a%s']+)%.$"

--[[
  CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS
  [source] [keyword] [number] [source] [spell]

  examples:
    $player$ gains $amount$ Energy from $player$'s Restore Energy.
]]--
local SPELL_PERIODIC_HOSTILE_PLAYER_BUFFS2 = "^(%a+)%s(gains)%s(%d+)%s%a+%sfrom%s(%a+)'s%s([%a%s]+)%.$"

--[[
  CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS
  [source] [keyword] [spell] [charges]

  Charges can be going up or down

  e.g. $player$ gains Restless Strength (20).
  e.g. $player$ gains Restless Strength (19).
  e.g. $player$ gains Restless Strength (18).
  etc.

  e.g $player$ gains Combustion (0).
  e.g $player$ gains Combustion (1).

  examples:
    $player$ gains Restless Strength (20).
    $player$ gains Combustion (0).
]]--
local SPELL_PERIODIC_HOSTILE_PLAYER_BUFFS3 = "^(%a+)%s(gains)%s([%a%s']+)%s([%d+%(%)]+)%.$"

--[[
  CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
  [source] [spell] [keyword] [source] [number]

  examples:
    $player$'s Minor Healthstone heals $player$ for $amount$.
]]--
local SPELL_HOSTILE_PLAYER_BUFF1 = "^(%a+)'s%s([%a%s]+)%s(heals)%s(%a+)%sfor%s(%d+)%.$"

--[[
  CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
  [source] [keyword] [spell]

  examples:
    $player$ casts Explosive Trap.
    $player$ casts Freezing Trap.
]]--
local SPELL_HOSTILE_PLAYER_BUFF2 = "^(%a+)%s(casts)%s([%a%s]+)%.$"

--[[
  CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
  [source] [keyword] [spell]

  examples:
    $player$ begins to perform Escape Artist.
]]--
local SPELL_HOSTILE_PLAYER_BUFF3 = "^(%a+)%s(begins to perform)%s([%a%s]+)%.$"

--[[
  CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
  [source] [spell] [keyword] [source] [number]

  examples:
    $player$'s Lay on Hands critically heals $player$ for $amount$.

]]--
local SPELL_HOSTILE_PLAYER_BUFF4 = "^(%a+)'s%s([%a%s]+)%s(critically heals)%s(%a+)%sfor%s(%d+)%.$"


--[[
  CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF
  [source] [keyword] [number] [resource] [keyword][source] [spell]

  examples:
    $player$ gains $amount$ Energy from $player$'s Restore Energy.
    $player$ gains $amount$ Rage from $player$'s Bloodrage.
]]--
local SPELL_HOSTILE_PLAYER_BUFF5 = "^(%a+)%s(gains)%s(%d+)%s([%a]+)%s(from)%s(%a+)'s%s([%a%s]+)%.$"

--[[
  CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
  [source] [keyword] [spell]

  examples:
    You are afflicted by Fear.
    You are afflicted by Curse of Tongues.
    You are afflicted by Polymorph.
    You are afflicted by Polymorph: Pig.
    You are afflicted by Counterspell - Silenced.
]]--
local SPELL_PERIODIC_SELF_DAMAGE = "^(You)%sare%s(afflicted)%sby%s([%a%s:-]+)%.$"

--[[
  CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
  [source] [spell] [keyword] [target] [number]

  examples:
    $player$'s Pummel hits you for 100.
]]--
local SPELL_HOSTILEPLAYER_DAMAGE1 = "^(%a+)'s%s([%a%s]+)%s(hits)%s(you)%sfor%s(%d+)%.$"

--[[
  CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
  [source] [spell] [keyword] [target] [number]

  examples:
    $player$'s Pummel crits you for 100.
]]--
local SPELL_HOSTILEPLAYER_DAMAGE2 = "^(%a+)'s%s([%a%s]+)%s(crits)%s(you)%sfor%s(%d+)%.$"

--[[
  CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE
  [source] [keyword] [spell]

  examples:
    $player$ begins to cast Hammer of Wrath.
]]--
local SPELL_HOSTILEPLAYER_DAMAGE3 = "^(%a+)%s(begins to cast)%s([%a%s]+)%.$"

--[[
  CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE
  [target] [keyword] [spell]

  examples:
    $player$ is afflicted by Forbearance.
]]--
local SPELL_PERIODIC_HOSTILE_PLAYER_DAMAGE = "^(%a+)%sis%s(afflicted)%sby%s([%a%s'-:]+)%.$"

--[[
  CHAT_MSG_SPELL_AURA_GONE_OTHER
  [spell] [keyword] [source]

  examples:
    Fire Reflector fades from $player$.
]]--
local SPELL_AURA_GONE_OTHER = "^([%a%s']+)%s(fades)%sfrom%s(%a+)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF
  [source] [spell] [keyword] [target]

  examples:
    Your Wrath was resisted by $player$.
    Your Faerie Fire was resisted by $player$.

]]--
local SPELL_DAMAGESHIELDS_ON_SELF1 = "^(Your)%s([%a%s'-:]+)%swas%s(resisted)%sby%s(%a+)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF
  [source] [spell] [keyword] [target] [keyword2]

  examples:
    Your Faerie Fire failed. $player$ is immune.
    Your Silence failed. $player$ is immune.
]]--
local SPELL_DAMAGESHIELDS_ON_SELF2 = "^(Your)%s([%a%s'-:]+)%s(failed)%.%s(%a+)%sis%s(immune)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF
  [source] [spell] [keyword] [target]

  example:
    Your Bash missed $player$.
    Your Aimed Shot missed $player$.
]]--
local SPELL_DAMAGESHIELDS_ON_SELF3 = "^(Your)%s([%a%s'-:]+)%s(missed)%s(%a+)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF
  [source] [spell] [keyword] [target]

  examples:
    Your Wing Clip was dodged by $player$.
    Your Disarm was dodged by $player$.
]]--
local SPELL_DAMAGESHIELDS_ON_SELF4 = "^(Your)%s([%a%s'-:]+)%swas%s(dodged)%sby%s(%a+)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF
  [source] [spell] [keyword] [target]

  examples:
    Your Disarm is parried by $player$.
    Your Execute is parried by $player$.
]]--
local SPELL_DAMAGESHIELDS_ON_SELF5 = "^(Your)%s([%a%s'-:]+)%sis%s(parried)%sby%s(%a+)%.$"


--[[
  CHAT_MSG_SPELL_SELF_DAMAGE
  [source] [spell] [keyword] [target]

  examples:
    Your Kick was blocked by $player$.
    Your Sinister Strike was blocked by $player$.
    Your Eviscerate was blocked by $player$.
]]--
local SPELL_SELF_DAMAGE = "^(Your)%s([%a%s'-:]+)%swas%s(blocked)%sby%s(%a+)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS
  [source] [spell] [keyword]

  examples:
    $player$'s Counterspell was resisted.
]]--
local SPELL_DAMAGESHIELDS_ON_OTHERS1 = "^(%a+)'s%s([%a%s'-:]+)%swas%s(resisted)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS
  [source] [spell] [keyword]

  examples:
    $player$'s Kick was blocked.
    $player$'s Wing Clip was blocked.
]]--
local SPELL_DAMAGESHIELDS_ON_OTHERS2 = "^(%a+)'s%s([%a%s'-:]+)%swas%s(blocked)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS
  [source] [spell] [keyword]

  examples:
    $player$'s Blind misses you.
]]--
local SPELL_DAMAGESHIELDS_ON_OTHERS3 = "^(%a+)'s%s([%a%s'-:]+)%s(misses)%syou%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS
  [source] [spell] [keyword] [keyword]

  examples:
    $player$'s Blind failed. You are immune.
]]--
local SPELL_DAMAGESHIELDS_ON_OTHERS4 = "^(%a+)'s%s([%a%s'-:]+)%s(failed)%.%sYou%sare%s(immune)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS
  [source] [spell] [keyword]

  examples:
    $player$'s Kick was parried.
]]--
local SPELL_DAMAGESHIELDS_ON_OTHERS5 = "^(%a+)'s%s([%a%s'-:]+)%swas%s(parried)%.$"

--[[
  CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS
  [source] [spell] [keyword]

  examples:
    $player$'s Kick was dodged.
]]--
local SPELL_DAMAGESHIELDS_ON_OTHERS6 = "^(%a+)'s%s([%a%s'-:]+)%swas%s(dodged)%.$"

--[[
  @param {string} msg
  @param {string} eventType
  @return {number, table | number}
    3 successfully parsed a friendly spell avoided message
    2 successfully parsed a enemy spell avoided message
    1 successfully parsed a spell announce message
    0 if not able to parse message
    nil if message eventType was unknown
]]--
function me.ParseCombatText(msg, eventType)
  mod.logger.LogDebug(me.tag, "Received combat text message: " .. msg)

  local status = 0, spellData

  if eventType == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" then
    status, spellData = me.ParseSpellPeriodicSelfDamage(msg)
  elseif eventType == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS" then
    status, spellData = me.ParseSpellPeriodicHostilePlayerBuffs(msg)
  elseif eventType == "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF" then
    status, spellData = me.ParseSpellHostilePlayerBuff(msg)
  elseif eventType == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE" then
    status, spellData = me.ParseSpellHostilePlayerDamage(msg)
  elseif eventType == "CHAT_MSG_SPELL_AURA_GONE_OTHER" then
    status, spellData = me.ParseSpellAuraGoneOther(msg)
  elseif eventType == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF" then
    status, spellData = me.ParseSpellDamageShieldsOnSelf(msg)
  elseif eventType == "CHAT_MSG_SPELL_SELF_DAMAGE" then
    status, spellData = me.ParseSpellSelfDamage(msg)
  elseif eventType == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS" then
    status, spellData = me.ParseSpellDamageShieldsOnOthers(msg)
  elseif eventType == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" then
    status, spellData = me.ParseSpellPeriodicHostilePlayerDamage(msg)
  end

  if status == 1 then
    mod.logger.LogDebug(me.tag, "Successfully parsed combatText")
    return status, spellData
  end

  return status
end

--[[
  Parse combat text for CHAT_MSG_SPELL_AURA_GONE_OTHER event

  @param {string} msg
    combat text to parse
  @return {number, table | number}
    1 if msg could be parsed
    0 if not able to parse msg
]]--
function me.ParseSpellAuraGoneOther(msg)
  local _, _, spell, keyword, source = string.find(msg, SPELL_AURA_GONE_OTHER)

  if spell and keyword and source then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_AURA_GONE_OTHER detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_AURA_GONE_OTHER",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL_DOWN,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["source"] = source,
      ["faded"] = true
    }
  end

  -- unable to parse message
  mod.logger.LogInfo(me.tag, "Failed to parse CHAT_MSG_SPELL_AURA_GONE_OTHER")
  return 0
end

--[[
  Parse combat text for CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS event

  @param {string} msg
    combat text to parse
  @return {number, table | number}
    1 if msg could be parsed
    0 if not able to parse msg
]]--
function me.ParseSpellPeriodicHostilePlayerBuffs(msg)
  local _, _, source, keyword, spell = string.find(msg, SPELL_PERIODIC_HOSTILE_PLAYER_BUFFS1)

  if source and keyword and spell then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["source"] = source,
      ["keyword"] = keyword,
      ["spell"] = spell
    }
  end

  local _, _, player1, keyword, amount, player2, spell = string.find(msg, SPELL_PERIODIC_HOSTILE_PLAYER_BUFFS2)

  if player1 and keyword and amount and player2 and spell then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", player1, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["source"] = source,
      ["player1"] = player1,
      ["player2"] = player2,
      ["keyword1"] = keyword1,
      ["keyword2"] = keyword2,
      ["spell"] = spell
    }
  end

  local _, _, source, keyword, spell, charges = string.find(msg, SPELL_PERIODIC_HOSTILE_PLAYER_BUFFS3)

  if source and keyword and spell and charges then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS detected")
    -- ignore spells with charges
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS successfully parsed but ignoring spell")
  end

  -- unable to parse message
  mod.logger.LogInfo(me.tag, "Failed to parse CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
  return 0
end

--[[
  Parse combat text for CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF event

  @param {string} msg
    combat text to parse
  @return {number, table | number}
    1 if msg could be parsed
    0 if not able to parse msg
]]--
function me.ParseSpellHostilePlayerBuff(msg)
  local _, _, player1, spell, keyword, player2, amount = string.find(msg, SPELL_HOSTILE_PLAYER_BUFF1)

  if player1 and spell and keyword and player2 and amount then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF detected")
    mod.logger.LogDebug(me.tag, string.format("player: %s spell: %s amount: %s", player1, spell, amount))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["player1"] = player1,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["player2"] = player2,
      ["amount"] = amount
    }
  end

  local _, _, player, keyword, spell = string.find(msg, SPELL_HOSTILE_PLAYER_BUFF2)

  if player and keyword and spell then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF detected")
    mod.logger.LogDebug(me.tag, string.format("player: %s spell: %s", player, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["player"] = player,
      ["keyword"] = keyword,
      ["spell"] = spell
    }
  end

  local _, _, source, keyword, spell = string.find(msg, SPELL_HOSTILE_PLAYER_BUFF3)

  if source and keyword and spell then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword
    }
  end

  local _, _, source1, spell, keyword, source2, amount = string.find(msg, SPELL_HOSTILE_PLAYER_BUFF4)

  if source1 and spell and keyword and source2 and amount then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF detected")
    mod.logger.LogDebug(me.tag, string.format("source1: %s spell: %s source2: %s", source1, spell, source2))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["source1"] = source1,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["source2"] = source2,
      ["amount"] = amount
    }
  end

  local _, _, source1, keyword1, amount, resource, keyword2, source2, spell = string.find(msg, SPELL_HOSTILE_PLAYER_BUFF5)

  if source1 and keyword1 and amount and resource and keyword2 and source2 and spell then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF detected")
    mod.logger.LogDebug(me.tag, string.format("source1: %s spell: %s source2: %s", source1, spell, source2))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["source1"] = source1,
      ["keyword1"] = keyword1,
      ["amount"] = amount,
      ["resource"] = resource,
      ["keyword2"] = keyword2,
      ["source2"] = source2,
      ["spell"] = spell
    }
  end

  -- unable to parse message
  mod.logger.LogInfo(me.tag, "Failed to parse CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
  return 0
end

--[[
  Parse combat text for CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE event

  @param {string} msg
    combat text to parse
  @return {number, table | number}
    1 if msg could be parsed
    0 if not able to parse msg
]]--
function me.ParseSpellPeriodicSelfDamage(msg)
  local _, _, source, keyword, spell = string.find(msg, SPELL_PERIODIC_SELF_DAMAGE)

  if source and keyword and spell then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["source"] = source,
      ["keyword"] = keyword,
      ["spell"] = spell
    }
  end

  -- unable to parse message
  mod.logger.LogInfo(me.tag, "Failed to parse CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
  return 0
end

--[[
  Parse combat text for CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE event

  @param {string} msg
    combat text to parse
  @return {number, table | number}
    1 if msg could be parsed
    0 if not able to parse msg
]]--
function me.ParseSpellHostilePlayerDamage(msg)
  local _, _, source, spell, keyword, target, damage = string.find(msg, SPELL_HOSTILEPLAYER_DAMAGE1)

  if source and spell and keyword and target and damage then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["target"] = target,
      ["damage"] = damage
    }
  end

  local _, _, source, spell, keyword, target, damage = string.find(msg, SPELL_HOSTILEPLAYER_DAMAGE2)

  if source and spell and keyword and target and damage then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["target"] = target,
      ["damage"] = damage
    }
  end

  local _, _, source, keyword, spell = string.find(msg, SPELL_HOSTILEPLAYER_DAMAGE3)

  if source and keyword and spell then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["source"] = source,
      ["keyword"] = keyword,
      ["spell"] = spell
    }
  end

  -- unable to parse message
  mod.logger.LogInfo(me.tag, "Failed to parse CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
  return 0
end

--[[
  Parse combat text for CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE event

  @param {string} msg
    combat text to parse
  @return {number, table | number}
    1 if msg could be parsed
    0 if not able to parse msg
]]--
function me.ParseSpellPeriodicHostilePlayerDamage(msg)
  local _, _, target, keyword, spell = string.find(msg, SPELL_PERIODIC_HOSTILE_PLAYER_DAMAGE)

  if target and keyword and spell then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE detected")
    mod.logger.LogDebug(me.tag, string.format("target: %s spell: %s", target, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SPELL,
      ["target"] = target,
      ["keyword"] = keyword,
      ["spell"] = spell
    }
  end

  -- unable to parse message
  mod.logger.LogInfo(me.tag, "Failed to parse CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
  return 0
end

--[[
  Parse combat text for CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF event

  @param {string} msg
    combat text to parse
  @return {number, table | number}
    1 if msg could be parsed
    0 if not able to parse msg
]]--
function me.ParseSpellDamageShieldsOnSelf(msg)
  local _, _, source, spell, keyword, target = string.find(msg, SPELL_DAMAGESHIELDS_ON_SELF1)

  if source and spell and keyword and target then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF detected")
    mod.logger.LogDebug(me.tag, string.format("spell: %s target: %s", spell, target))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.ENEMY_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["target"] = target
    }
  end

  local _, _, source, spell, keyword, target, keyword2 = string.find(msg, SPELL_DAMAGESHIELDS_ON_SELF2)

  if source and spell and keyword and target and keyword2 then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF detected")
    mod.logger.LogDebug(me.tag, string.format("spell: %s target: %s", spell, target))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.ENEMY_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["target"] = target,
      ["keyword2"] = keyword2
    }
  end

  local _, _, source, spell, keyword, target = string.find(msg, SPELL_DAMAGESHIELDS_ON_SELF3)

  if source and spell and keyword and target then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF detected")
    mod.logger.LogDebug(me.tag, string.format("spell: %s target: %s", spell, target))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.ENEMY_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["target"] = target
    }
  end

  local _, _, source, spell, keyword, target = string.find(msg, SPELL_DAMAGESHIELDS_ON_SELF4)

  if source and spell and keyword and target then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF detected")
    mod.logger.LogDebug(me.tag, string.format("spell: %s target: %s", spell, target))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.ENEMY_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["target"] = target
    }
  end

  local _, _, source, spell, keyword, target = string.find(msg, SPELL_DAMAGESHIELDS_ON_SELF5)

  if source and spell and keyword and target then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF detected")
    mod.logger.LogDebug(me.tag, string.format("spell: %s target: %s", spell, target))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.ENEMY_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["target"] = target
    }
  end

  -- unable to parse message
  mod.logger.LogInfo(me.tag, "Failed to parse CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
  return 0
end

--[[
  Parse combat text for CHAT_MSG_SPELL_SELF_DAMAGE event

  @param {string} msg
    combat text to parse
  @return {number, table | number}
    1 if msg could be parsed
    0 if not able to parse msg
]]--
function me.ParseSpellSelfDamage(msg)
  local _, _, source, spell, keyword, target = string.find(msg, SPELL_SELF_DAMAGE)

  if source and spell and keyword and target then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_SELF_DAMAGE detected")
    mod.logger.LogDebug(me.tag, string.format("spell: %s target: %s", spell, target))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_SELF_DAMAGE",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.ENEMY_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword,
      ["target"] = target
    }
  end

  -- unable to parse message
  mod.logger.LogInfo(me.tag, "Failed to parse CHAT_MSG_SPELL_SELF_DAMAGE")
  return 0
end

--[[
  Parse combat text for CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS event

  @param {string} msg
    combat text to parse
  @return {number, table | number}
    1 if msg could be parsed
    0 if not able to parse msg
]]--
function me.ParseSpellDamageShieldsOnOthers(msg)
  local _, _, source, spell, keyword = string.find(msg, SPELL_DAMAGESHIELDS_ON_OTHERS1)

  if source and spell and keyword then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SELF_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword
    }
  end

  local _, _, source, spell, keyword = string.find(msg, SPELL_DAMAGESHIELDS_ON_OTHERS2)

  if source and spell and keyword then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SELF_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword
    }
  end

  local _, _, source, spell, keyword = string.find(msg, SPELL_DAMAGESHIELDS_ON_OTHERS3)

  if source and spell and keyword then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SELF_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword
    }
  end

  local _, _, source, spell, keyword1, keyword2 = string.find(msg, SPELL_DAMAGESHIELDS_ON_OTHERS4)

  if source and spell and keyword1 and keyword2 then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SELF_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword
    }
  end

  local _, _, source, spell, keyword = string.find(msg, SPELL_DAMAGESHIELDS_ON_OTHERS5)

  if source and spell and keyword then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SELF_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword
    }
  end

  local _, _, source, spell, keyword = string.find(msg, SPELL_DAMAGESHIELDS_ON_OTHERS6)

  if source and spell and keyword then
    mod.logger.LogDebug(me.tag, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS detected")
    mod.logger.LogDebug(me.tag, string.format("source: %s spell: %s", source, spell))

    return 1, {
      ["type"] = "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS",
      ["soundType"] = PVPW_CONSTANTS.SOUND_TYPES.SELF_AVOIDED,
      ["source"] = source,
      ["spell"] = spell,
      ["keyword"] = keyword
    }
  end

  -- unable to parse message
  mod.logger.LogInfo(me.tag, "Failed to parse CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS")
  return 0
end
