# Development

## Spellmaps

### SpellMap

Spelltemplate:

```
["category"] = {
  ["spellname"] = {
    ["name"] = "",
    ["soundFileName"] = "",
    ["spellId"] = ,
    ["spellIcon"] = "",
    ["hasFade"] = ,
    ["active"] =
  }
}
```

For a full explanation of the fields see `PVPW_SpellMap.lua`

### SpellAvoidMap

The SpellAvoidMap contains spells that can be avoided by either the player itself
or and enemy.

Spelltemplate:

```
["category"] = {
  ["spell_name"] = {
    ["name"] = "",
    ["soundFileName"] = "",
    ["itemId"] = ,
    ["spellId"] = ,
    ["spellIcon"] = "",
    ["hasFade"] = ,
    ["canCrit"] = ,
    ["links"] = ,
    ["active"] = ,
    ["ignoreEvents"] = []
  }
}
```

For a full explanation of the fields see `PVPW_SpellAvoidMap.lua`

## Adding New Spells

Adding a new spell that is not out of the ordinary and can already be detected by the addon
can be achieved with the following steps.

A new spell requires at least one new sound file that needs to be categorized in one of the available categories. Depending on whether the new spell is an `enemy_avoid` or `self_avoid` or a normal `spell` it has to be placed in the correct folder.

normal_spell:

`Assets\Sounds\[Locale][Category]\[spellname].mp3`

normal_spell_down:

`Assets\Sounds\[Locale][Category]\[spellname]_down.mp3`

enemy_avoid:

`Assets\Sounds\[Locale][Category]\enemy_avoid\enemy_avoided_[spellname].mp3`

self_avoid:

`Assets\Sounds\[Locale][Category]\enemy_avoid\you_avoided_[spellname].mp3`

Additionally depending on the type of the new spell certain tests should be written. Usually two types of tests should be written. One test is for testing the ability to play the sound file while the other should check if the spell combat message is parseable by the parser.

## Warn Flow

This Flowchart describes the flow that a combat log event is running through.

![](/Docs/pvpw_warn_flow.png)

The addon listens to certain combat log events such as `CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE`. For a full list of events that are parseable check `PVPW_Parser.lua`.

If such an event is both tracked and parseable it reaches the next stage. From the event the detected spell is searched in one of the Spellmaps depending on the type of the combat log message. If the spell is one of the spells the addon can handle it checks then if the spell is activated as well. Only after those steps the warning is added to the queue.

## WarnQueue Flow

The WarnQueue Flowchart describes how the addon works through the queue of detected warnings.

![](/Docs/pvpw_queue_flow.png)

While the `WarnQueueWorker` is working through the queue in a fast interval of 0.1 seconds only one event per second can be shown/played to the player. This is to prevent visual and acoustic events overlapping with other warnings. It is still helpful to have a fast worker to work on an event as fast as possible as soon as it is put to the queue. We have to assume that most of the time the queue will be empty. As soon as an event is prepared for playing the queue is set to busy for 1 second. During this time the worker will skip each tick until the queue is free for work again.

## Linked Spells

Spells with the exact same name have to be linked together because there is no way to differentiate them just from the combatlog.

If there are spells with the same name other then the current one your working on in the spellmap they have to be linked.

Example:

Spell `Nature's Swiftness`
Druid: id `17116`
Shaman: id: `16188`

```lua
["natures_swiftness"] = {
  ["name"] = "Nature's Swiftness",
  ["soundFileName"] = "natures_swiftness",
  ["spellId"] = 17116, -- druid spellid
  ["spellIcon"] = "spell_nature_ravenform",
  ["hasFade"] = true,
  ["links"] = { 16188 }, -- link to shaman spell id
  ["active"] = true
}

["natures_swiftness"] = {
  ["name"] = "Nature's Swiftness",
  ["soundFileName"] = "natures_swiftness",
  ["spellId"] = 16188, -- shaman spellid
  ["spellIcon"] = "spell_nature_ravenform",
  ["hasFade"] = true,
  ["links"] = { 17116 }, -- link to druid spell id
  ["active"] = true
}
```

**Note:** A spell can have multiple links

Once the spells are linked together they share the same configuration. Test this by changing a property and verify that the same property was changed for all the links as well.
