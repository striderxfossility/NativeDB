
public class TogglePlayerFlashlightEffector extends Effector {

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.ProcessEffector(owner.GetGame(), false);
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.ProcessEffector(owner.GetGame(), true);
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.ProcessEffector(game, true);
  }

  private final func ProcessEffector(game: GameInstance, enable: Bool) -> Void {
    let evt: ref<TogglePlayerFlashlightEvent> = new TogglePlayerFlashlightEvent();
    evt.enable = enable;
    let player: ref<PlayerPuppet> = GetPlayer(game);
    player.QueueEvent(evt);
  }
}
