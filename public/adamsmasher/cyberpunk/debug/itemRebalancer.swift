
public class DEBUG_ItemRebalancer extends GameObject {

  public let m_nodeRef: NodeRef;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
    EntityRequestComponentsInterface.RequestComponent(ri, n"choice", n"InteractionComponent", false);
  }

  protected cb func OnInteractionChoice(evt: ref<InteractionChoiceEvent>) -> Bool {
    switch evt.choice.choiceMetaData.tweakDBName {
      case "Rebalance":
        this.RebalanceItem();
        break;
      default:
    };
  }

  private final func RebalanceItem() -> Void {
    let statSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    let evt: ref<DEBUG_RebalanceItemEvent> = new DEBUG_RebalanceItemEvent();
    let playerLevel: Float = statSystem.GetStatValue(Cast(player.GetEntityID()), gamedataStatType.Level);
    evt.reqLevel = playerLevel;
    let entityID: EntityID = Cast(ResolveNodeRefWithEntityID(this.m_nodeRef, this.GetEntityID()));
    this.QueueEventForEntityID(entityID, evt);
  }
}
