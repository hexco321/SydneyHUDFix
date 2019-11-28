local init_original = SentryGunWeapon.init
function SentryGunWeapon:init(...)
    init_original(self, ...)
    managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), { ammo_ratio = self:ammo_ratio() })
    if tweak_data.blackmarket.deployables[self._unit:base():get_type()] then
        managers.enemy:add_delayed_clbk("sentry_post_init_" .. tostring(self._unit:key()), callback(self, self, "post_init"), Application:time() + 0.1)
    end
end

local change_ammo_original = SentryGunWeapon.change_ammo
function SentryGunWeapon:change_ammo(...)
    change_ammo_original(self, ...)
    managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), { ammo_ratio = self:ammo_ratio() })
end

local sync_ammo_original = SentryGunWeapon.sync_ammo
function SentryGunWeapon:sync_ammo(...)
    sync_ammo_original(self, ...)
    managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), { ammo_ratio = self:ammo_ratio() })
end

local load_original = SentryGunWeapon.load
function SentryGunWeapon:load(...)
    load_original(self, ...)
    managers.gameinfo:event("sentry", "set_ammo_ratio", tostring(self._unit:key()), { ammo_ratio = self:ammo_ratio() })
end

local destroy_original = SentryGunWeapon.destroy
function SentryGunWeapon:destroy(...)
    managers.enemy:remove_delayed_clbk("sentry_post_init_" .. tostring(self._unit:key()))
    destroy_original(self, ...)
end

function SentryGunWeapon:post_init()
    local enable_ap = self._unit:base():is_owner() and managers.player:has_category_upgrade("sentry_gun", "ap_bullets") or false

    if SydneyHUD:GetOption("auto_sentry_ap") and enable_ap then
        if alive(self._fire_mode_unit) and alive(self._unit) then
            local firemode_interaction = self._fire_mode_unit:interaction()
            if firemode_interaction and firemode_interaction:can_interact(managers.player:player_unit()) then
                self:_set_fire_mode(true)
                self._unit:network():send("sentrygun_sync_armor_piercing", self._use_armor_piercing)
                self._unit:event_listener():call("on_switch_fire_mode", self._use_armor_piercing)
            end
        end
    end
end