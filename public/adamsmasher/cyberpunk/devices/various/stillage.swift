
public class Stillage extends InteractiveDevice {

  private let m_collider: ref<IPlacedComponent>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"collider", n"entColliderComponent", false);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_collider = EntityResolveComponentsInterface.GetComponent(ri, n"collider") as IPlacedComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as StillageController;
  }

  protected cb func OnThrowStuff(evt: ref<ThrowStuff>) -> Bool {
    this.EnterWorkspot(evt.GetExecutor(), false, n"playerWorkspot", n"deviceWorkspot");
  }

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    super.OnWorkspotFinished(componentName);
    this.m_collider.Toggle(false);
  }

  protected cb func OnQuestResetDeviceToInitialState(evt: ref<QuestResetDeviceToInitialState>) -> Bool {
    let e3_animFeatureInjection: ref<AnimFeature_DeviceWorkspot> = new AnimFeature_DeviceWorkspot();
    e3_animFeatureInjection.e3_lockInReferencePose = true;
    this.ApplyAnimFeatureToReplicate(this, n"DeviceWorkspot", e3_animFeatureInjection);
    this.m_collider.Toggle(true);
  }
}
