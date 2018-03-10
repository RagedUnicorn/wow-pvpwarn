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
mod.profile = me

me.tag = "Profile"

-- allow for a maximum of 10 profiles
local maxProfiles = 10
local maxProfileNameLength = 25

--[[
  ["type"] = {
    -- e.g. paladin, racials
    ["spellName"] = {
      -- e.g. lay_on_hands as found in SpellMap
      ["spellActive"] = false,
        -- default false
      ["soundWarningActive"] = false,
        -- default false
      ["soundFadeWarningActive"] = false,
        -- default false
      ["visualWarningActive"] = false,
        -- default false
      ["visualWarningColor"] = [number] -- e.g. blue, orange see PVPW_CONSTANTS.TEXTURES
        -- default color in PVPW_CONSTANTS.DEFAULT_COLOR
    }
  }
]]--
local defaultProfile = {}

-- Default self avoided spells that are activated and alerted to the player
local defaultProfileSelfAvoidSpells = {
  ["rogue"] = {},
  ["warrior"] = {},
  ["mage"] = {},
  ["warlock"] = {},
  ["hunter"] = {},
  ["paladin"] = {},
  ["priest"] = {},
  ["druid"] = {},
  ["shaman"] = {}
}

-- Default enemy avoided spells that are activated and alerted to the player
local defaultProfileEnemyAvoidSpells = {
  ["rogue"] = {},
  ["warrior"] = {},
  ["mage"] = {},
  ["warlock"] = {},
  ["hunter"] = {},
  ["paladin"] = {},
  ["priest"] = {},
  ["druid"] = {},
  ["shaman"] = {}
}

--[[
  Default profiles consider the class from the player that uses the addon. As an
  example lets assume the player is a warrior. What are the spells a warrior absolutely
  needs to know of. Depending on the class a spells importance might greatly differ
  from very important to not interested in all.
]]--

-- default profile for player class warrior
local defaultProfileWarrior
local defaultProfilePriest
local defaultProfileRogue
local defaultProfileMage
local defaultProfileWarlock
local defaultProfilePaladin
local defaultProfileDruid

if (GetLocale() == "deDE") then
  defaultProfileWarrior = {
    ["warrior"] = {
      ["tollkuehnheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["schildwall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["letztes_gefecht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["todeswunsch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["seele_der_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      },
      ["inneres_feuer"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprinten"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenalinrausch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["klingenwirbel"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["eisblock"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arkane_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["geistesgegenwart"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kuh"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_schwein"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kroete"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["blinzeln"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["eiskaeltefalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frostfalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["abschreckung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["furcht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["handauflegung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["segen_des_schutzes"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["gottesschild"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_des_zorns"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["segen_der_freiheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_der_gerechtigkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["busse"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["baumrinde"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["griff_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {

    },
    ["items"] = {
      ["immunitaet_gegen_unbeweglichkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["gedankensprung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["net_o_matik"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["erste_hilfe"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["eisengranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thoriumgranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["unverwundbarkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["freie_aktion"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfilePriest = {
    ["warrior"] = {
      ["tollkuehnheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["schildwall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["letztes_gefecht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["todeswunsch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["berserkerwut"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["seele_der_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      },
      ["furchtzauberschutz"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprinten"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenalinrausch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["klingenwirbel"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["eisblock"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arkane_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["geistesgegenwart"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kuh"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_schwein"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kroete"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["eiskaeltefalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frostfalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["furcht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["teufelsbeherschung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["schattenzauberschutz"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["handauflegung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["gottesschild"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_des_zorns"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["segen_der_freiheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_der_gerechtigkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["busse"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["anregen"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["totem_der_erdung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["totem_des_erdstosses"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {
      ["schattenreflektor"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["erste_hilfe"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["eisengranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thoriumgranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["schattenschutz"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfileRogue = {
    ["warrior"] = {
      ["tollkuehnheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["schildwall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["letztes_gefecht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["todeswunsch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["seele_der_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      },
      ["inneres_feuer"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprinten"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenalinrausch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["klingenwirbel"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["eisblock"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arkane_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["geistesgegenwart"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kuh"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_schwein"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kroete"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["blinzeln"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["eiskaeltefalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frostfalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["abschreckung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["leuchtfeuer"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["furcht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["handauflegung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["segen_des_schutzes"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["gottesschild"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_des_zorns"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["segen_der_freiheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_der_gerechtigkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["busse"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["baumrinde"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["griff_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {
      ["immunitaet_gegen_unbeweglichkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["gedankensprung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["net_o_matik"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["fliehen"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["erste_hilfe"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["eisengranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thoriumgranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["unverwundbarkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["freie_aktion"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfileMage = {
    ["warrior"] = {
      ["tollkuehnheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["schildwall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["letztes_gefecht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["todeswunsch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["seele_der_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprinten"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["eisblock"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arkane_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["geistesgegenwart"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kuh"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_schwein"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kroete"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["eiskaeltefalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frostfalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["furcht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["handauflegung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["gottesschild"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_des_zorns"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["segen_der_freiheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_der_gerechtigkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["busse"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["totem_des_erdstosses"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {
      ["feuerreflektor"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["frostreflektor"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["immunitaet_gegen_unbeweglichkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["erste_hilfe"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["eisengranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thoriumgranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["freie_aktion"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["frostschutz"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["feuerschutz"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfileWarlock = {
    ["warrior"] = {
      ["tollkuehnheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["schildwall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["letztes_gefecht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["todeswunsch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["berserkerwut"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["seele_der_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      },
      ["furchtzauberschutz"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprinten"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenalinrausch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["klingenwirbel"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["eisblock"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arkane_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["geistesgegenwart"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kuh"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_schwein"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kroete"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["eiskaeltefalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frostfalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["furcht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["schattenzauberschutz"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["handauflegung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["gottesschild"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_des_zorns"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["hammer_der_gerechtigkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["busse"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["totem_des_erdstosses"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["totem_der_erdung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {
      ["feuerreflektor"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["frostreflektor"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["erste_hilfe"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["eisengranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thoriumgranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["schattenschutz"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["feuerschutz"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfilePaladin = {
    ["warrior"] = {
      ["tollkuehnheit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["schildwall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["letztes_gefecht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["todeswunsch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["seele_der_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprinten"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenalinrausch"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["klingenwirbel"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["eisblock"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arkane_macht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["geistesgegenwart"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kuh"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_schwein"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["verwandlung_kroete"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["eiskaeltefalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frostfalle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["furcht"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["handauflegung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["gottesschild"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_des_zorns"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_der_gerechtigkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["busse"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["schnelligkeit_der_natur"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["totem_der_erdung"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {

    },
    ["misc"] = {
      ["erste_hilfe"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["eisengranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thoriumgranate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["unverwundbarkeit"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }
else
  defaultProfileWarrior = {
    ["warrior"] = {
      ["recklessness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["shield_wall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["last_stand"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["death_wish"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["power_infusion"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      },
      ["inner_fire"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprint"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenaline_rush"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["blade_flurry"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["ice_block"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arcane_power"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["presence_of_mind"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_cow"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_pig"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_turtle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["blink"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["freezing_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frost_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["deterrence"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["fear"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["lay_on_hands"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["blessing_of_protection"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["divine_shield"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_wrath"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["blessing_of_freedom"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_justice"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["repentance"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["barkskin"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["natures_grasp"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {

    },
    ["items"] = {
      ["immune_root"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["mind_quickening"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["net_o_matic"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["first_aid"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["iron_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thorium_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["invulnerability"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["free_action"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfilePriest = {
    ["warrior"] = {
      ["recklessness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["shield_wall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["last_stand"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["death_wish"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["berserker_rage"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["power_infusion"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      },
      ["fear_ward"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprint"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenaline_rush"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["blade_flurry"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["ice_block"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arcane_power"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["presence_of_mind"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_cow"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_pig"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_turtle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["freezing_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frost_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["fear"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["fel_domination"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["shadow_ward"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["lay_on_hands"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["divine_shield"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_wrath"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["blessing_of_freedom"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_justice"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["repentance"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["innervate"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["grounding_totem"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["tremor_totem"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {
      ["shadow_reflector"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["first_aid"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["iron_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thorium_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["shadow_protection"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfileRogue = {
    ["warrior"] = {
      ["recklessness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["shield_wall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["last_stand"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["death_wish"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["power_infusion"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      },
      ["inner_fire"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprint"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenaline_rush"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["blade_flurry"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["ice_block"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arcane_power"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["presence_of_mind"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_cow"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_pig"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_turtle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["blink"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["freezing_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frost_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["deterrence"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["flare"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["fear"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["lay_on_hands"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["blessing_of_protection"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["divine_shield"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_wrath"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["blessing_of_freedom"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_justice"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["repentance"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["barkskin"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["natures_grasp"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {
      ["immune_root"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["mind_quickening"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["net_o_matic"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["flee"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["first_aid"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["iron_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thorium_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["invulnerability"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["free_action"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfileMage = {
    ["warrior"] = {
      ["recklessness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["shield_wall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["last_stand"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["death_wish"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["power_infusion"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprint"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["ice_block"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arcane_power"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["presence_of_mind"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_cow"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_pig"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_turtle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["freezing_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frost_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["fear"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["lay_on_hands"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["divine_shield"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_wrath"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["blessing_of_freedom"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_justice"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["repentance"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["tremor_totem"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {
      ["fire_reflector"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["frost_reflector"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["immune_root"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["first_aid"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["iron_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thorium_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["free_action"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["frost_protection"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["fire_protection"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfileWarlock = {
    ["warrior"] = {
      ["recklessness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["shield_wall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["last_stand"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["death_wish"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["berserker_rage"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["power_infusion"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      },
      ["fear_ward"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprint"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenaline_rush"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["blade_flurry"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["ice_block"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arcane_power"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["presence_of_mind"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_cow"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_pig"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_turtle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["freezing_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frost_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["fear"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      },
      ["shadow_ward"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["lay_on_hands"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["divine_shield"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_wrath"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["hammer_of_justice"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["repentance"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["tremor_totem"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["grounding_totem"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {
      ["fire_reflector"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["shadow_reflector"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    },
    ["misc"] = {
      ["first_aid"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["iron_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thorium_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["shadow_protection"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["fire_protection"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }

  defaultProfilePaladin = {
    ["warrior"] = {
      ["recklessness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["shield_wall"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["last_stand"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      },
      ["death_wish"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 7
      }
    },
    ["priest"] = {
      ["power_infusion"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 8
      }
    },
    ["rogue"] = {
      ["sprint"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["adrenaline_rush"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      },
      ["blade_flurry"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 1
      }
    },
    ["mage"] = {
      ["ice_block"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["arcane_power"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["presence_of_mind"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_cow"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_pig"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      },
      ["polymorph_turtle"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 10
      }
    },
    ["hunter"] = {
      ["freezing_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      },
      ["frost_trap"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 5
      }
    },
    ["warlock"] = {
      ["fear"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 2
      }
    },
    ["paladin"] = {
      ["lay_on_hands"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
      ["divine_shield"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_wrath"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["hammer_of_justice"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      },
      ["repentance"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 9
      }
    },
    ["druid"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["shaman"] = {
      ["natures_swiftness"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      },
      ["grounding_totem"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 6
      }
    },
    ["racials"] = {
    },
    ["items"] = {

    },
    ["misc"] = {
      ["first_aid"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = false,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["iron_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["thorium_grenade"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      },
      ["invulnerability"] = {
        ["spellActive"] = true,
        ["soundWarningActive"] = true,
        ["soundFadeWarningActive"] = true,
        ["visualWarningActive"] = true,
        ["visualWarningColor"] = 3
      }
    }
  }
end

function me.GetDefaultProfile()
  local playerClass = string.lower(mod.common.GetPlayerClassName())
  mod.logger.LogError(me.tag, "playerClass: " .. playerClass)

  if playerClass == PVPW_CLASSLIST[1] then
    return defaultProfileWarrior
  else

  end
end

function me.GetDefaultProfileEnemyAvoidSpells()
  return defaultProfileEnemyAvoidSpells
end

function me.GetDefaultProfileSelfAvoidSpells()
  return defaultProfileSelfAvoidSpells
end

function me.GetMaxProfileNameLength()
  return maxProfileNameLength
end

--[[
  Add a new profile to the list of profiles

  @param {string} profileName
  @param {table} spellConfiguration
  @param {table} selfAvoidSpellConfiguration
  @param {table} spellEnemyAvoidList
]]--
function me.AddNewProfile(profileName, spellConfiguration, selfAvoidSpellConfiguration, enemyAvoidSpellConfiguration)
  if table.getn(PVPWarnProfiles) >= maxProfiles then
    mod.logger.PrintUserError(
      string.format(pvpw.L["user_message_add_new_profile_max_reached"], maxProfiles)
    )
    return
  end

  for i = 1, table.getn(PVPWarnProfiles) do
    if PVPWarnProfiles[i].name == profileName then
      mod.logger.PrintUserError(pvpw.L["user_message_select_profile_already_exists"])
      return
    end
  end

  local profile = {
    name = profileName,
    ["spellConfiguration"] = mod.common.Clone(spellConfiguration),
    ["selfAvoidSpellConfiguration"] = mod.common.Clone(selfAvoidSpellConfiguration),
    ["enemyAvoidSpellConfiguration"] = mod.common.Clone(enemyAvoidSpellConfiguration)
  }

  table.insert(PVPWarnProfiles, profile)
  mod.logger.LogDebug(me.tag, "Created new profile with name - " .. profileName)
end

--[[
  Delete the profile on the passed index

  @param {number} index
]]--
function me.DeleteProfile(index)
  table.remove(PVPWarnProfiles, index)
  mod.logger.LogDebug(me.tag, "Removed profile on index " .. index)
end

--[[
  Activate the profile found at the passed index
  Important! Values have to be cloned because lua does not copy by value on tables

  @param {number} index
]]--
function me.ActivateProfile(index)
  PVPWarnOptions.spellList = nil
  PVPWarnOptions.spellList = mod.common.Clone(PVPWarnProfiles[index].spellConfiguration)
  PVPWarnOptions.spellSelfAvoidList = nil
  PVPWarnOptions.spellSelfAvoidList = mod.common.Clone(PVPWarnProfiles[index].selfAvoidSpellConfiguration)
  PVPWarnOptions.spellEnemyAvoidList = nil
  PVPWarnOptions.spellEnemyAvoidList = mod.common.Clone(PVPWarnProfiles[index].enemyAvoidSpellConfiguration)
end

--[[
  Activate the profile found at the passed index
  Important! Values have to be cloned because lua does not copy by value on tables

  @param {number} index
]]--
function me.ActivateDefaultProfile()
  PVPWarnOptions.spellList = nil
  -- get the default configuration based on the current class
  PVPWarnOptions.spellList = mod.common.Clone(me.GetDefaultProfile())
  PVPWarnOptions.spellSelfAvoidList = nil
  PVPWarnOptions.spellSelfAvoidList = mod.common.Clone(defaultProfileSelfAvoidSpells)
  PVPWarnOptions.spellEnemyAvoidList = nil
  PVPWarnOptions.spellEnemyAvoidList = mod.common.Clone(defaultProfileEnemyAvoidSpells)
end
