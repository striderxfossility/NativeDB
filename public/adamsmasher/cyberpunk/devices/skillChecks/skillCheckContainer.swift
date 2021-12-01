
public abstract class BaseSkillCheckContainer extends IScriptable {

  protected persistent let m_hackingCheckSlot: ref<HackingSkillCheck>;

  protected persistent let m_engineeringCheckSlot: ref<EngineeringSkillCheck>;

  protected persistent let m_demolitionCheckSlot: ref<DemolitionSkillCheck>;

  public func Initialize(container: ref<BaseSkillCheckContainer>) -> Void;

  public final func InitializeBackdoor(difficulty: EGameplayChallengeLevel) -> Void {
    if !IsDefined(this.m_hackingCheckSlot) {
      this.m_hackingCheckSlot = new HackingSkillCheck();
    };
    if !this.m_hackingCheckSlot.IsPassed() {
      this.m_hackingCheckSlot.m_alternativeName = t"Interactions.ConnectPersonalLink";
      this.m_hackingCheckSlot.m_difficulty = difficulty;
      this.m_hackingCheckSlot.SetDuration(1.00);
      this.m_hackingCheckSlot.Initialize();
    };
  }

  public final const func GetEngineeringSlot() -> ref<EngineeringSkillCheck> {
    return this.m_engineeringCheckSlot;
  }

  public final const func GetDemolitionSlot() -> ref<DemolitionSkillCheck> {
    return this.m_demolitionCheckSlot;
  }

  public final const func GetHackingSlot() -> ref<HackingSkillCheck> {
    return this.m_hackingCheckSlot;
  }

  protected final func TryToInitialize(slotToInitialize: ref<SkillCheckBase>) -> Void {
    if slotToInitialize != null {
      slotToInitialize.Initialize();
    };
  }
}

public class HackingContainer extends BaseSkillCheckContainer {

  public inline let m_hackingCheck: ref<HackingSkillCheck>;

  public func Initialize(container: ref<BaseSkillCheckContainer>) -> Void {
    let myContainer: ref<HackingContainer> = container as HackingContainer;
    if myContainer == null {
      return;
    };
    if !IsDefined(this.m_hackingCheckSlot) || !this.m_hackingCheckSlot.IsPassed() {
      this.m_hackingCheckSlot = myContainer.m_hackingCheck;
      this.TryToInitialize(this.m_hackingCheckSlot);
    };
  }
}

public class EngineeringContainer extends BaseSkillCheckContainer {

  public inline let m_engineeringCheck: ref<EngineeringSkillCheck>;

  public func Initialize(container: ref<BaseSkillCheckContainer>) -> Void {
    let myContainer: ref<EngineeringContainer> = container as EngineeringContainer;
    if myContainer == null {
      return;
    };
    if !IsDefined(this.m_engineeringCheckSlot) || !this.m_engineeringCheckSlot.IsPassed() {
      this.m_engineeringCheckSlot = myContainer.m_engineeringCheck;
      this.TryToInitialize(this.m_engineeringCheckSlot);
    };
  }
}

public class DemolitionContainer extends BaseSkillCheckContainer {

  public inline let m_demolitionCheck: ref<DemolitionSkillCheck>;

  public func Initialize(container: ref<BaseSkillCheckContainer>) -> Void {
    let myContainer: ref<DemolitionContainer> = container as DemolitionContainer;
    if myContainer == null {
      return;
    };
    if !IsDefined(this.m_demolitionCheckSlot) || !this.m_demolitionCheckSlot.IsPassed() {
      this.m_demolitionCheckSlot = myContainer.m_demolitionCheck;
      this.TryToInitialize(this.m_demolitionCheckSlot);
    };
  }
}

public class EngDemoContainer extends BaseSkillCheckContainer {

  public inline let m_engineeringCheck: ref<EngineeringSkillCheck>;

  public inline let m_demolitionCheck: ref<DemolitionSkillCheck>;

  public func Initialize(container: ref<BaseSkillCheckContainer>) -> Void {
    let myContainer: ref<EngDemoContainer> = container as EngDemoContainer;
    if myContainer == null {
      return;
    };
    if !IsDefined(this.m_engineeringCheckSlot) || !this.m_engineeringCheckSlot.IsPassed() {
      this.m_engineeringCheckSlot = myContainer.m_engineeringCheck;
      this.TryToInitialize(this.m_engineeringCheckSlot);
    };
    if !IsDefined(this.m_demolitionCheckSlot) || !this.m_demolitionCheckSlot.IsPassed() {
      this.m_demolitionCheckSlot = myContainer.m_demolitionCheck;
      this.TryToInitialize(this.m_demolitionCheckSlot);
    };
  }
}

public class HackEngContainer extends BaseSkillCheckContainer {

  public inline let m_hackingCheck: ref<HackingSkillCheck>;

  public inline let m_engineeringCheck: ref<EngineeringSkillCheck>;

  public func Initialize(container: ref<BaseSkillCheckContainer>) -> Void {
    let myContainer: ref<HackEngContainer> = container as HackEngContainer;
    if myContainer == null {
      return;
    };
    if !IsDefined(this.m_hackingCheckSlot) || !this.m_hackingCheckSlot.IsPassed() {
      this.m_hackingCheckSlot = myContainer.m_hackingCheck;
      this.TryToInitialize(this.m_hackingCheckSlot);
      if IsDefined(this.m_hackingCheckSlot) && this.m_hackingCheckSlot.GetDuration() == 0.00 {
        this.m_hackingCheckSlot.SetDuration(3.00);
      };
    };
    if !IsDefined(this.m_engineeringCheckSlot) || !this.m_engineeringCheckSlot.IsPassed() {
      this.m_engineeringCheckSlot = myContainer.m_engineeringCheck;
      this.TryToInitialize(this.m_engineeringCheckSlot);
    };
  }
}

public class GenericContainer extends BaseSkillCheckContainer {

  public inline let m_hackingCheck: ref<HackingSkillCheck>;

  public inline let m_engineeringCheck: ref<EngineeringSkillCheck>;

  public inline let m_demolitionCheck: ref<DemolitionSkillCheck>;

  public func Initialize(container: ref<BaseSkillCheckContainer>) -> Void {
    let myContainer: ref<GenericContainer> = container as GenericContainer;
    if myContainer == null {
      return;
    };
    if !IsDefined(this.m_hackingCheckSlot) || !this.m_hackingCheckSlot.IsPassed() {
      this.m_hackingCheckSlot = myContainer.m_hackingCheck;
      this.TryToInitialize(this.m_hackingCheckSlot);
    };
    if !IsDefined(this.m_engineeringCheckSlot) || !this.m_engineeringCheckSlot.IsPassed() {
      this.m_engineeringCheckSlot = myContainer.m_engineeringCheck;
      this.TryToInitialize(this.m_engineeringCheckSlot);
    };
    if !IsDefined(this.m_demolitionCheckSlot) || !this.m_demolitionCheckSlot.IsPassed() {
      this.m_demolitionCheckSlot = myContainer.m_demolitionCheck;
      this.TryToInitialize(this.m_demolitionCheckSlot);
    };
  }
}
