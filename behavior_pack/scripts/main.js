import { world } from "@minecraft/server";

world.afterEvents.entityHitEntity.subscribe((event) => {
  const attacker = event.damagingEntity;
  const victim = event.hitEntity;

  const equipment = attacker.getComponent("minecraft:equippable");
  if (!equipment) return;

  const mainHand = equipment.getEquipment("Mainhand");
  if (!mainHand || mainHand.typeId !== "everything:mega_sword") return;

  if (!victim.isValid) return;

  const dimension = victim.dimension;
  const location = victim.location;

  try {
    dimension.spawnEntity("minecraft:lightning_bolt", location);
    dimension.spawnParticle("minecraft:large_explosion", location);
  } catch (e) {
    console.warn(`[MegaSword] Failed to spawn effects: ${e}`);
  }
});
