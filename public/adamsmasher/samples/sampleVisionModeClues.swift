
public class sampleVisClueMaster extends GameObject {

  private const let m_dependableEntities: array<NodeRef>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision", n"VisionModeComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_visionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"vision") as VisionModeComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    this.m_visionComponent.SetHiddenInVisionMode(true, gameVisionModeType.Default);
  }

  protected cb func OnInteractionChoice(choice: ref<InteractionChoiceEvent>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_dependableEntities) {
      GameInstance.GetVisionModeSystem(this.GetGame()).SetChildEntityVisionMode(this.GetEntityID(), this.m_dependableEntities[i], true);
      i += 1;
    };
  }

  private final func IsModeOn() -> Bool {
    let isFocusOn: Int32 = GameInstance.GetQuestsSystem(this.GetGame()).GetFact(n"isFocusOn");
    if isFocusOn == 1 {
      return true;
    };
    if isFocusOn == 0 {
      return false;
    };
    Log("Wrong isFocusOn value");
    return false;
  }
}

public class sampleVisClueSlave extends GameObject {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision", n"VisionModeComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_visionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"vision") as VisionModeComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    this.m_visionComponent.SetHiddenInVisionMode(true, gameVisionModeType.Default);
    GameInstance.GetVisionModeSystem(this.GetGame()).SetEntityVisionMode(this.GetEntityID(), false);
  }

  protected cb func OnInteractionChoice(choice: ref<InteractionChoiceEvent>) -> Bool;

  private final func IsModeOn() -> Bool {
    let isFocusOn: Int32 = GameInstance.GetQuestsSystem(this.GetGame()).GetFact(n"isFocusOn");
    if isFocusOn == 1 {
      return true;
    };
    if isFocusOn == 0 {
      return false;
    };
    Log("Wrong isFocusOn value");
    return false;
  }
}
