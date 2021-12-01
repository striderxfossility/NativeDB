
public class InspectDummy extends GameObject {

  public let m_mesh: ref<PhysicalMeshComponent>;

  public let m_choice: ref<InteractionComponent>;

  public let m_inspectComp: ref<InspectableObjectComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"inspectComponent", n"InspectableObjectComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"mesh", n"PhysicalMeshComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"interaction", n"InteractionComponent", true);
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision", n"gameVisionModeComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_mesh = EntityResolveComponentsInterface.GetComponent(ri, n"mesh") as PhysicalMeshComponent;
    this.m_inspectComp = EntityResolveComponentsInterface.GetComponent(ri, n"inspectComponent") as InspectableObjectComponent;
    this.m_choice = EntityResolveComponentsInterface.GetComponent(ri, n"interaction") as InteractionComponent;
  }

  protected cb func OnInteractionChoice(choice: ref<InteractionChoiceEvent>) -> Bool {
    let inspectEvt: ref<InspectItemInspectionEvent>;
    let lootEvt: ref<LootItemInspectionEvent>;
    switch choice.choice.choiceMetaData.tweakDBName {
      case "Inspect":
        inspectEvt = new InspectItemInspectionEvent();
        inspectEvt.owner = choice.activator;
        this.QueueEvent(inspectEvt);
        break;
      case "Loot":
        lootEvt = new LootItemInspectionEvent();
        lootEvt.owner = choice.activator;
        this.QueueEvent(lootEvt);
    };
  }
}

public class InspectableItemObject extends ItemObject {

  public edit const let m_inspectableClues: array<SInspectableClue>;

  protected final func DisplayScanButton(show: Bool) -> Void;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool;

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool;

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
  }

  public final const func IsClueScanned(clueName: CName) -> Bool {
    return Cast(GetFact(this.GetGame(), clueName));
  }

  protected cb func OnInteractionActivated(evt: ref<InteractionActivationEvent>) -> Bool {
    let isScanned: Bool = this.IsClueScanned(evt.layerData.tag);
    let newEvt: ref<ScanEvent> = new ScanEvent();
    if Equals(evt.eventType, gameinteractionsEInteractionEventType.EIET_activate) {
      newEvt.isAvailable = true;
      newEvt.clue = NameToString(evt.layerData.tag);
      if GetFact(this.GetGame(), evt.layerData.tag) == 0 {
        this.DisplayScanButton(true);
      };
      if isScanned {
      };
    } else {
      newEvt.isAvailable = false;
      newEvt.clue = "";
      this.DisplayScanButton(false);
    };
    this.QueueEventForEntityID(evt.activator.GetEntityID(), newEvt);
  }
}
