
public class CleaningMachineController extends BasicDistractionDeviceController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class CleaningMachineControllerPS extends BasicDistractionDeviceControllerPS {

  protected inline let m_cleaningMachineSkillChecks: ref<EngDemoContainer>;

  protected cb func OnInstantiated() -> Bool {
    super.OnInstantiated();
  }

  protected func Initialize() -> Void {
    this.Initialize();
  }

  protected func GameAttached() -> Void;

  protected func LogicReady() -> Void {
    this.LogicReady();
    this.InitializeSkillChecks(this.m_cleaningMachineSkillChecks);
  }
}
