-- clones a weapon preset and optionally sets values for all weapons contained in that preset
-- if the value is a function, it calls the function with the data of the value name instead
local function based_on(preset, values)
  local p = deep_clone(preset)
  if not values then
    return p
  end
  for _, entry in pairs(p) do
    for val_name, val in pairs(values) do
      if type(val) == "function" then
        val(entry[val_name])
      else
        entry[val_name] = val
      end
    end
  end
  return p
end


local function manipulate_entries(tbl, value_name, func)
  for _, v in pairs(tbl) do
    if type(v) == "table" then
      v[value_name] = func(v[value_name])
    end
  end
end


local character_map_original = CharacterTweakData.character_map
function CharacterTweakData:character_map(...)
  local char_map = character_map_original(self, ...)
  table.insert(char_map.basic.list, "ene_swat_heavy_r870")
  table.insert(char_map.basic.list, "ene_fbi_heavy_r870")
  table.insert(char_map.basic.list, "ene_swat_3")
  table.insert(char_map.basic.list, "ene_fbi_swat_3")
  table.insert(char_map.gitgud.list, "ene_zeal_swat_2")
  table.insert(char_map.gitgud.list, "ene_zeal_swat_3")
  table.insert(char_map.gitgud.list, "ene_zeal_swat_heavy_r870")
  return char_map
end


local _presets_original = CharacterTweakData._presets
function CharacterTweakData:_presets(tweak_data, ...)
  local presets = _presets_original(self, tweak_data, ...)

  -- setup weapon presets
  local dmg_mul_tbl = { 0.1, 0.2, 0.4, 0.7, 1, 2, 4, 7 }
  local acc_mul_tbl = { 0.75, 0.8, 0.85, 0.9, 1, 1.1, 1.2, 1.3 }
  local focus_delay_tbl = { 1.8, 1.6, 1.4, 1.2, 1, 0.8, 0.6, 0.4 }
  local aim_delay_tbl = { 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1 }
  local melee_dmg_tbl = { 1, 2, 4, 7, 10, 13, 16, 20 }

  local x = tweak_data:difficulty_to_index(Global.game_settings and Global.game_settings.difficulty or "normal")
  local x_norm = (x - 1) / 7
  local aim_delay = { 0, aim_delay_tbl[x] }
  local dmg_mul = dmg_mul_tbl[x]
  local acc_mul = acc_mul_tbl[x]

  presets.weapon.cass_base = based_on(presets.weapon.expert, {
    focus_delay = focus_delay_tbl[x],
    aim_delay = aim_delay,
    melee_dmg = melee_dmg_tbl[x]
  })
  presets.weapon.cass_base.is_pistol.FALLOFF = {
    { dmg_mul = 6 * dmg_mul, r = 0, acc = { 0.6 * acc_mul, 0.9 * acc_mul }, recoil = { 0.2, 0.3 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 3 * dmg_mul, r = 3000, acc = { 0.1 * acc_mul, 0.4 * acc_mul }, recoil = { 0.4, 1 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_base.akimbo_pistol.FALLOFF = {
    { dmg_mul = 6 * dmg_mul, r = 0, acc = { 0.5 * acc_mul, 0.8 * acc_mul }, recoil = { 0.05, 0.1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 3 * dmg_mul, r = 3000, acc = { 0, 0.3 * acc_mul }, recoil = { 0.2, 0.6 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_base.is_revolver.FALLOFF = {
    { dmg_mul = 4 * dmg_mul, r = 0, acc = { 0.8 * acc_mul, 1 * acc_mul }, recoil = { 0.75, 1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 2 * dmg_mul, r = 3000, acc = { 0.3 * acc_mul, 0.6 * acc_mul }, recoil = { 1, 1.5 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_base.is_sniper = deep_clone(presets.weapon.cass_base.is_revolver)
  presets.weapon.cass_base.is_sniper.FALLOFF = {
    { dmg_mul = 6 * dmg_mul, r = 0, acc = { 0, 0.5 * acc_mul }, recoil = { 1, 1.5 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 6 * dmg_mul, r = 1000, acc = { 0.5 * acc_mul, 1 * acc_mul }, recoil = { 1, 1.5 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 4 * dmg_mul, r = 10000, acc = { 0.25 * acc_mul, 0.5 * acc_mul }, recoil = { 1, 1.5 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_base.is_shotgun_pump.FALLOFF = {
    { dmg_mul = 1.75 * dmg_mul, r = 0, acc = { 0.8 * acc_mul, 1 * acc_mul }, recoil = { 0.75, 1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 1.25 * dmg_mul, r = 1000, acc = { 0.5 * acc_mul, 0.8 * acc_mul }, recoil = { 1, 1.5 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 0.01 * dmg_mul, r = 3000, acc = { 0.1 * acc_mul, 0.6 * acc_mul }, recoil = { 1.5, 2 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_base.is_shotgun_pump.range = { optimal = 1000, far = 3000, close = 500 }
  presets.weapon.cass_base.is_shotgun_mag = deep_clone(presets.weapon.cass_base.is_shotgun_pump)
  presets.weapon.cass_base.is_rifle.autofire_rounds = { 3, 9 }
  presets.weapon.cass_base.is_rifle.FALLOFF = {
    { dmg_mul = 3 * dmg_mul, r = 0, acc = { 0.6 * acc_mul, 0.9 * acc_mul }, recoil = { 0.3, 0.6 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 1 * dmg_mul, r = 3000, acc = { 0.1 * acc_mul, 0.3 * acc_mul }, recoil = { 1.5, 2 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_base.is_bullpup = deep_clone(presets.weapon.cass_base.is_rifle)
  presets.weapon.cass_base.is_smg.autofire_rounds = { 4, 16 }
  presets.weapon.cass_base.is_smg.FALLOFF = {
    { dmg_mul = 5 * dmg_mul, r = 0, acc = { 0.5 * acc_mul, 0.8 * acc_mul }, recoil = { 0.1, 0.3 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 0.5 * dmg_mul, r = 3000, acc = { 0, 0 }, recoil = { 1, 1.5 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_base.is_smg.range = { optimal = 1500, far = 4000, close = 750 }
  presets.weapon.cass_base.mini.autofire_rounds = { 50, 200 }
  presets.weapon.cass_base.mini.FALLOFF = {
    { dmg_mul = 4 * dmg_mul, r = 0, acc = { 0.5 * acc_mul, 0.8 * acc_mul }, recoil = { 0.4, 0.8 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 3 * dmg_mul, r = 1000, acc = { 0.4 * acc_mul, 0.6 * acc_mul }, recoil = { 0.5, 1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 2 * dmg_mul, r = 3000, acc = { 0, 0.35 * acc_mul }, recoil = { 1, 2 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_base.is_lmg.autofire_rounds = { 10, 40 }
  presets.weapon.cass_base.is_lmg.FALLOFF = {
    { dmg_mul = 2 * dmg_mul, r = 0, acc = { 0.5 * acc_mul, 0.8 * acc_mul }, recoil = { 0.4, 0.8 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 1.5 * dmg_mul, r = 1000, acc = { 0.4 * acc_mul, 0.6 * acc_mul }, recoil = { 0.5, 1 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 1 * dmg_mul, r = 3000, acc = { 0, 0.35 * acc_mul }, recoil = { 1, 2 }, mode = { 1, 0, 0, 0 } }
  }

  -- heavy preset (deal less damage in exchange for being bulkier)
  presets.weapon.cass_heavy = based_on(presets.weapon.cass_base, {
    FALLOFF = function (falloff)
      manipulate_entries(falloff, "dmg_mul", function (val) return val * 0.8 end)
    end
  })

  -- bulldozer preset
  local dmg_mul = math.lerp(0.6, 1.3, x_norm)
  presets.weapon.cass_tank = based_on(presets.weapon.cass_base, {
    melee_dmg = 25
  })
  presets.weapon.cass_tank.is_shotgun_pump.RELOAD_SPEED = 1
  presets.weapon.cass_tank.is_shotgun_pump.FALLOFF = {
    { dmg_mul = 5 * dmg_mul, r = 0, acc = { 0.6, 0.9 }, recoil = { 1.5, 2 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 2 * dmg_mul, r = 1000, acc = { 0.2, 0.75 }, recoil = { 1.5, 2 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 0.1 * dmg_mul, r = 3000, acc = { 0.05, 0.35 }, recoil = { 1.5, 2 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_tank.is_shotgun_mag.RELOAD_SPEED = 0.5
  presets.weapon.cass_tank.is_shotgun_mag.autofire_rounds = { 1, 7 }
  presets.weapon.cass_tank.is_shotgun_mag.FALLOFF = {
    { dmg_mul = 2 * dmg_mul, r = 0, acc = { 0.6, 0.9 }, recoil = { 0.4, 0.7 }, mode = { 1, 0, 0, 0 }, autofire_rounds = { 3, 4 } },
    { dmg_mul = 1.5 * dmg_mul, r = 1000, acc = { 0.4, 0.8 }, recoil = { 0.45, 0.8 }, mode = { 1, 0, 0, 0 }, autofire_rounds = { 1, 3 } },
    { dmg_mul = 0.5 * dmg_mul, r = 3000, acc = { 0.1, 0.35 }, recoil = { 1, 1.2 }, mode = { 1, 0, 0, 0 }, autofire_rounds = { 1, 1 } }
  }
  presets.weapon.cass_tank.is_rifle.focus_dis = 800
  presets.weapon.cass_tank.is_rifle.RELOAD_SPEED = 0.5
  presets.weapon.cass_tank.is_rifle.autofire_rounds = { 20, 40 }
  presets.weapon.cass_tank.is_rifle.FALLOFF = {
    { dmg_mul = 4 * dmg_mul, r = 0, acc = { 0.6, 0.9 }, recoil = { 0.4, 0.7 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 3 * dmg_mul, r = 1000, acc = { 0.4, 0.6 }, recoil = { 0.45, 0.8 }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 2 * dmg_mul, r = 3000, acc = { 0.1, 0.35 }, recoil = { 1, 1.2 }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_tank.mini.focus_dis = 800
  presets.weapon.cass_tank.mini.RELOAD_SPEED = 1
  presets.weapon.cass_tank.mini.autofire_rounds = { 40, 700 }
  presets.weapon.cass_tank.mini.FALLOFF = {
    { dmg_mul = 4 * dmg_mul, r = 0, acc = { 0.1, 0.15 }, recoil = { 2, 2 }, mode = { 1, 0, 0, 0 }, autofire_rounds = { 500, 700 } },
    { dmg_mul = 3 * dmg_mul, r = 1000, acc = { 0.04, 0.075 }, recoil = { 1.2, 1.5 }, mode = { 1, 0, 0, 0 }, autofire_rounds = { 300, 500 } },
    { dmg_mul = 2 * dmg_mul, r = 3000, acc = { 0.01, 0.025 }, recoil = { 0.5, 0.7 }, mode = { 1, 0, 0, 0 }, autofire_rounds = { 40, 100 } }
  }

  -- sniper presets
  local dmg_mul = math.lerp(0.6, 1.3, x_norm)
  local recoil_mul = math.lerp(1.3, 0.6, x_norm)
  presets.weapon.cass_sniper = based_on(presets.weapon.sniper, {
    focus_delay = 10,
    aim_delay = aim_delay,
  })
  presets.weapon.cass_sniper.is_rifle.FALLOFF = {
    { dmg_mul = 9 * dmg_mul, r = 0, acc = { 0, 0.5 }, recoil = { 3 * recoil_mul, 5 * recoil_mul }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 9 * dmg_mul, r = 1000, acc = { 0.5, 1 }, recoil = { 3 * recoil_mul, 5 * recoil_mul }, mode = { 1, 0, 0, 0 } },
    { dmg_mul = 7 * dmg_mul, r = 10000, acc = { 0.25, 0.5 }, recoil = { 3 * recoil_mul, 5 * recoil_mul }, mode = { 1, 0, 0, 0 } }
  }
  presets.weapon.cass_sniper_heavy = based_on(presets.weapon.cass_sniper, {
    focus_delay = 5,
    FALLOFF = function (falloff)
      manipulate_entries(falloff, "dmg_mul", function (val) return val * 0.5 end)
      manipulate_entries(falloff, "recoil", function (val) return { val[1] * 0.5, val[2] * 0.5 } end)
    end
  })

  -- give team ai more reasonable preset values
  presets.weapon.gang_member = based_on(presets.weapon.cass_base)

  -- setup surrender presets
  local surrender_factors = {
    unaware_of_aggressor = 0.1,
    enemy_weap_cold = 0.1,
    flanked = 0.05,
    isolated = 0.1,
    aggressor_dis = {
      [300.0] = 0.2,
      [1000.0] = 0
    }
  }
  presets.surrender.easy = {
    base_chance = 0.3,
    significant_chance = 0.35,
    factors = surrender_factors,
    reasons = {
      pants_down = 1,
      weapon_down = 0.5,
      health = {
        [1.0] = 0,
        [0.8] = 0.8
      }
    }
  }
  presets.surrender.normal = {
    base_chance = 0.3,
    significant_chance = 0.3,
    factors = surrender_factors,
    reasons = {
      pants_down = 0.9,
      weapon_down = 0.4,
      health = {
        [1.0] = 0,
        [0.6] = 0.6
      }
    }
  }
  presets.surrender.hard = {
    base_chance = 0.3,
    significant_chance = 0.25,
    factors = surrender_factors,
    reasons = {
      pants_down = 0.8,
      weapon_down = 0.3,
      health = {
        [1.0] = 0,
        [0.4] = 0.4
      }
    }
  }

  return presets
end


function CharacterTweakData:_multiply_weapon_delay(weap_usage_table, mul)
  -- wtf was that function overkill, always called with 0 values
end


function CharacterTweakData:_add_weapon(id, unit_name)
  table.insert(self.weap_ids, id)
  table.insert(self.weap_unit_names, Idstring(unit_name))
end


Hooks:PostHook(CharacterTweakData, "init", "cass_init", function(self)
  self:_add_weapon("spas12", "units/payday2/weapons/wpn_npc_spas12/wpn_npc_spas12")
  self:_add_weapon("mp7", "units/payday2/weapons/wpn_npc_mp7/wpn_npc_mp7")
  self:_add_weapon("amcar", "units/payday2/weapons/wpn_npc_amcar/wpn_npc_amcar")
  self:_add_weapon("aug", "units/payday2/weapons/wpn_npc_aug/wpn_npc_aug")

  self._default_preset_users = {}
  for _, name in ipairs(self._enemy_list) do
    if self[name].weapon == self.presets.weapon.normal or self[name].weapon == self.presets.weapon.good then
      self._default_preset_users[name] = self[name]
    end
  end

  -- set hurt severities for heavies
  self.heavy_swat.damage.hurt_severity = self.presets.hurt_severities.light_hurt_fire_poison
  self.fbi_heavy_swat.damage.hurt_severity = self.presets.hurt_severities.light_hurt_fire_poison
  self.heavy_swat_sniper.damage.hurt_severity = self.presets.hurt_severities.light_hurt_fire_poison

  -- set surrender chances (default is easy)
  self.swat.surrender = self.presets.surrender.normal
  self.heavy_swat.surrender = self.presets.surrender.hard
  self.fbi_swat.surrender = self.presets.surrender.normal
  self.fbi_heavy_swat.surrender = self.presets.surrender.hard
  self.city_swat.surrender = self.presets.surrender.normal
  self.heavy_swat_sniper.surrender = self.presets.surrender.hard

  -- restore special entrance announcements
  self.tank.spawn_sound_event = self.tank.speech_prefix_p1 .. "_entrance"
  self.tank_hw.spawn_sound_event = self.tank_hw.speech_prefix_p1 .. "_entrance"
  self.tank_medic.spawn_sound_event = self.tank_medic.speech_prefix_p1 .. "_entrance"
  self.tank_mini.spawn_sound_event = self.tank_mini.speech_prefix_p1 .. "_entrance"
  self.taser.spawn_sound_event = self.taser.speech_prefix_p1 .. "_entrance"
end)


local lower_preset_users = {
  heavy_swat = true,
  fbi_heavy_swat = true,
  medic = true
}
local function set_weapon_presets(self)
  for k, v in pairs(self._default_preset_users) do
    v.weapon = lower_preset_users[k] and self.presets.weapon.cass_heavy or self.presets.weapon.cass_base
  end
  self.tank.weapon = self.presets.weapon.cass_tank
  self.tank_hw.weapon = self.presets.weapon.cass_tank
  self.tank_medic.weapon = self.presets.weapon.cass_tank
  self.tank_mini.weapon = self.presets.weapon.cass_tank
  self.taser.weapon.is_rifle = deep_clone(self.presets.weapon.cass_base.is_rifle)
  self.taser.weapon.is_rifle.tase_sphere_cast_radius = 30
  self.taser.weapon.is_rifle.tase_distance = 1500
  self.taser.weapon.is_rifle.aim_delay_tase = { 0, 0 }
  self.shield.weapon = self.presets.weapon.cass_heavy
  self.phalanx_minion.weapon = self.presets.weapon.cass_heavy
  self.phalanx_vip.weapon = self.presets.weapon.cass_heavy
  self.spooc.weapon = self.presets.weapon.cass_base
  self.shadow_spooc.weapon = self.presets.weapon.cass_base
  self.sniper.weapon = self.presets.weapon.cass_sniper
  self.heavy_swat_sniper.weapon = self.presets.weapon.cass_sniper_heavy
end


Hooks:PostHook(CharacterTweakData, "_set_normal", "cass__set_normal", set_weapon_presets)
Hooks:PostHook(CharacterTweakData, "_set_hard", "cass__set_hard", set_weapon_presets)
Hooks:PostHook(CharacterTweakData, "_set_overkill", "cass__set_overkill", set_weapon_presets)
Hooks:PostHook(CharacterTweakData, "_set_overkill_145", "cass__set_overkill_145", set_weapon_presets)
Hooks:PostHook(CharacterTweakData, "_set_easy_wish", "cass__set_easy_wish", set_weapon_presets)
Hooks:PostHook(CharacterTweakData, "_set_overkill_290", "cass__set_overkill_290", set_weapon_presets)
Hooks:PostHook(CharacterTweakData, "_set_sm_wish", "cass__set_sm_wish", set_weapon_presets)
