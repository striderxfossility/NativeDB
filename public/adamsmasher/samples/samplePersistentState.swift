
public class SampleEntityWithCounterPS extends GameObjectPS {

  protected persistent let m_counter: Int32;

  public final const func ReadTheCounter() -> Int32 {
    return this.m_counter;
  }

  public final func OnBumpTheCounter(evt: ref<SampleBumpEvent>) -> EntityNotificationType {
    this.m_counter += evt.m_amount;
    Log("sample counter: " + IntToString(this.m_counter));
    return EntityNotificationType.SendThisEventToEntity;
  }
}

public class SampleEntityWithCounter extends GameObject {

  protected const func GetPS() -> ref<GameObjectPS> {
    return this.GetBasePS();
  }

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"SampleCounterDisplayComponent", n"SampleCounterDisplayComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let component: ref<SampleCounterDisplayComponent> = EntityResolveComponentsInterface.GetComponent(ri, n"SampleCounterDisplayComponent") as SampleCounterDisplayComponent;
    component.m_targetPersistentID = this.GetPersistentID();
  }

  public final func OnBumpTheCounter(evt: ref<SampleBumpEvent>) -> Void {
    Log("sample counter: bumped by " + IntToString(evt.m_amount));
  }
}

public class SampleInteractiveEntityThatBumpsTheCounter extends GameObject {

  public let m_targetEntityWithCounter: NodeRef;

  public let m_targetPersistentID: PersistentID;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"SampleCounterDisplayComponent", n"SampleCounterDisplayComponent", true);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    let component: ref<SampleCounterDisplayComponent> = EntityResolveComponentsInterface.GetComponent(ri, n"SampleCounterDisplayComponent") as SampleCounterDisplayComponent;
    this.m_targetPersistentID = Cast(ResolveNodeRefWithEntityID(this.m_targetEntityWithCounter, this.GetEntityID()));
    component.m_targetPersistentID = this.m_targetPersistentID;
  }

  protected cb func OnInteractionChoice(choice: ref<InteractionChoiceEvent>) -> Bool {
    let evt: ref<SampleBumpEvent> = new SampleBumpEvent();
    GameInstance.GetPersistencySystem(this.GetGame()).QueuePSEvent(this.m_targetPersistentID, n"SampleEntityWithCounterPS", evt);
  }
}

public class SampleCounterDisplayComponent extends ScriptableComponent {

  public let m_targetPersistentID: PersistentID;

  public final func OnUpdate(deltaTime: Float) -> Void {
    if PersistentID.IsDefined(this.m_targetPersistentID) {
      this.DisplayCounter();
    };
  }

  public final func DisplayCounter() -> Void {
    let psObject: ref<SampleEntityWithCounterPS> = this.GetPersistencySystem().GetConstAccessToPSObject(this.m_targetPersistentID, n"SampleEntityWithCounterPS") as SampleEntityWithCounterPS;
    let counterValue: Int32 = psObject.ReadTheCounter();
    this.GetDebugVisualizerSystem().DrawText3D(this.GetOwner().GetWorldPosition(), "Counter: " + IntToString(counterValue), new Color(0u, 255u, 0u, 255u), 0.00);
  }
}

public class SampleComponentWithCounterPS extends GameComponentPS {

  @default(SampleComponentWithCounterPS, 1000)
  protected persistent let m_counter: Int32;

  public final const func ReadTheCounter() -> Int32 {
    return this.m_counter;
  }

  public final func BumpTheCounter() -> Int32 {
    this.m_counter = this.m_counter + 1;
    return this.m_counter;
  }
}

public class SampleComponentWithCounter extends ScriptableComponent {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }

  public final func OnUpdate(deltaTime: Float) -> Void {
    let counterValue: Int32 = (this.GetPS() as SampleComponentWithCounterPS).BumpTheCounter();
    this.GetDebugVisualizerSystem().DrawText3D(this.GetOwner().GetWorldPosition(), "Counter: " + IntToString(counterValue), new Color(0u, 255u, 0u, 255u), 0.00);
  }
}
