
public class sampleVisWireMaster extends GameObject {

  private const let m_dependableEntities: array<NodeRef>;

  private let m_inFocus: Bool;

  private let m_found: Bool;

  private let m_lookedAt: Bool;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision", n"VisionModeComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_visionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"vision") as VisionModeComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    this.m_visionComponent.SetHiddenInVisionMode(true, gameVisionModeType.Default);
    this.m_inFocus = false;
    this.m_found = false;
    this.m_lookedAt = false;
  }

  protected cb func OnInteractionChoice(choice: ref<InteractionChoiceEvent>) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_dependableEntities) {
      GameInstance.GetVisionModeSystem(this.GetGame()).SetChildEntityVisionMode(this.GetEntityID(), this.m_dependableEntities[i], true);
      i += 1;
    };
  }

  protected cb func OnHUDInstruction(evt: ref<HUDInstruction>) -> Bool {
    super.OnHUDInstruction(evt);
    if Equals(evt.highlightInstructions.GetState(), InstanceState.ON) {
      this.m_inFocus = true;
      if !this.m_found && this.m_lookedAt && this.IsModeOn() {
        this.OnFound();
      };
    } else {
      if evt.highlightInstructions.WasProcessed() {
        this.m_inFocus = false;
      };
    };
  }

  private final func IsModeOn() -> Bool {
    return this.m_inFocus;
  }

  private final func OnFound() -> Void {
    let i: Int32;
    this.m_found = true;
    this.m_visionComponent.SetHiddenInVisionMode(false, gameVisionModeType.Default);
    i = 0;
    while i < ArraySize(this.m_dependableEntities) {
      GameInstance.GetVisionModeSystem(this.GetGame()).SetChildEntityVisionMode(this.GetEntityID(), this.m_dependableEntities[i], true);
      i += 1;
    };
  }
}

public class sampleVisWireSlave extends GameObject {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision", n"VisionModeComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_visionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"vision") as VisionModeComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    this.m_visionComponent.SetHiddenInVisionMode(true, gameVisionModeType.Focus);
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

public class sampleVisWireMasterTwo extends GameObject {

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

public class sampleVisWireSlaveTwo extends GameObject {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"vision", n"VisionModeComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_visionComponent = EntityResolveComponentsInterface.GetComponent(ri, n"vision") as VisionModeComponent;
  }

  protected cb func OnGameAttached() -> Bool {
    this.m_visionComponent.SetHiddenInVisionMode(true, gameVisionModeType.Focus);
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
