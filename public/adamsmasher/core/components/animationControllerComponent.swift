
public native class AnimationControllerComponent extends IComponent {

  private final native func PushEvent(eventName: CName) -> Void;

  private final native func SetInputFloat(inputName: CName, value: Float) -> Void;

  private final native func SetInputInt(inputName: CName, value: Int32) -> Void;

  private final native func SetInputBool(inputName: CName, value: Bool) -> Void;

  private final native func SetInputQuaternion(inputName: CName, value: Quaternion) -> Void;

  private final native func SetInputVector(inputName: CName, value: Vector4) -> Void;

  private final native func SetUsesSleepMode(allowSleepState: Bool) -> Void;

  private final native func ScheduleFastForward() -> Void;

  public final native func PreloadAnimations(streamingContextName: CName, highPriority: Bool) -> Bool;

  private final native func ApplyFeature(inputName: CName, value: ref<AnimFeature>) -> Void;

  public final native const func GetAnimationDuration(animationName: CName) -> Float;

  protected cb func OnSetInputVectorEvent(evt: ref<AnimInputSetterVector>) -> Bool {
    this.SetInputVector(evt.key, evt.value);
  }

  public final static func ApplyFeature(obj: ref<GameObject>, inputName: CName, value: ref<AnimFeature>, opt delay: Float) -> Void {
    let item: ref<ItemObject>;
    let evt: ref<AnimInputSetterAnimFeature> = new AnimInputSetterAnimFeature();
    evt.key = inputName;
    evt.value = value;
    evt.delay = delay;
    obj.QueueEvent(evt);
    item = obj as ItemObject;
    if IsDefined(item) {
      item.QueueEventToChildItems(evt);
    };
  }

  public final static func ApplyFeatureToReplicate(obj: ref<GameObject>, inputName: CName, value: ref<AnimFeature>, opt delay: Float) -> Void {
    AnimationControllerComponent.ApplyFeature(obj, inputName, value, delay);
    obj.ReplicateAnimFeature(obj, inputName, value);
  }

  public final static func ApplyFeatureToReplicateOnHeldItems(obj: ref<GameObject>, inputName: CName, value: ref<AnimFeature>, opt delay: Float) -> Void {
    let leftItem: ref<ItemObject> = GameInstance.GetTransactionSystem(obj.GetGame()).GetItemInSlot(obj, t"AttachmentSlots.WeaponLeft");
    let rightItem: ref<ItemObject> = GameInstance.GetTransactionSystem(obj.GetGame()).GetItemInSlot(obj, t"AttachmentSlots.WeaponRight");
    if IsDefined(leftItem) {
      AnimationControllerComponent.ApplyFeature(leftItem, inputName, value, delay);
      leftItem.ReplicateAnimFeature(leftItem, inputName, value);
    };
    if IsDefined(rightItem) {
      AnimationControllerComponent.ApplyFeature(rightItem, inputName, value, delay);
      rightItem.ReplicateAnimFeature(rightItem, inputName, value);
    };
  }

  public final static func PushEvent(obj: ref<GameObject>, eventName: CName) -> Void {
    let item: ref<ItemObject>;
    let evt: ref<AnimExternalEvent> = new AnimExternalEvent();
    evt.name = eventName;
    obj.QueueEvent(evt);
    item = obj as ItemObject;
    if IsDefined(item) {
      item.QueueEventToChildItems(evt);
    };
  }

  public final static func PushEventToObjAndHeldItems(obj: ref<GameObject>, eventName: CName) -> Void {
    let item: ref<ItemObject>;
    if !IsDefined(obj) {
      return;
    };
    AnimationControllerComponent.PushEvent(obj, eventName);
    item = GameInstance.GetTransactionSystem(obj.GetGame()).GetItemInSlot(obj, t"AttachmentSlots.WeaponLeft");
    if IsDefined(item) {
      AnimationControllerComponent.PushEvent(item, eventName);
    };
    item = GameInstance.GetTransactionSystem(obj.GetGame()).GetItemInSlot(obj, t"AttachmentSlots.WeaponRight");
    if IsDefined(item) {
      AnimationControllerComponent.PushEvent(item, eventName);
    };
  }

  public final static func PushEventToReplicate(obj: ref<GameObject>, eventName: CName) -> Void {
    AnimationControllerComponent.PushEvent(obj, eventName);
    obj.ReplicateAnimEvent(obj, eventName);
  }

  public final static func SetInputFloat(obj: ref<GameObject>, inputName: CName, value: Float) -> Void {
    let evt: ref<AnimInputSetterFloat> = new AnimInputSetterFloat();
    evt.key = inputName;
    evt.value = value;
    obj.QueueEvent(evt);
  }

  public final static func SetInputFloatToReplicate(obj: ref<GameObject>, inputName: CName, value: Float) -> Void {
    AnimationControllerComponent.SetInputFloat(obj, inputName, value);
    obj.ReplicateInputFloat(obj, inputName, value);
  }

  public final static func SetInputBool(obj: ref<GameObject>, inputName: CName, value: Bool) -> Void {
    let evt: ref<AnimInputSetterBool> = new AnimInputSetterBool();
    evt.key = inputName;
    evt.value = value;
    obj.QueueEvent(evt);
  }

  public final static func SetInputBoolToReplicate(obj: ref<GameObject>, inputName: CName, value: Bool) -> Void {
    AnimationControllerComponent.SetInputBool(obj, inputName, value);
    obj.ReplicateInputBool(obj, inputName, value);
  }

  public final static func SetInputInt(obj: ref<GameObject>, inputName: CName, value: Int32) -> Void {
    let evt: ref<AnimInputSetterInt> = new AnimInputSetterInt();
    evt.key = inputName;
    evt.value = value;
    obj.QueueEvent(evt);
  }

  public final static func SetInputIntToReplicate(obj: ref<GameObject>, inputName: CName, value: Int32) -> Void {
    AnimationControllerComponent.SetInputInt(obj, inputName, value);
    obj.ReplicateInputInt(obj, inputName, value);
  }

  public final static func SetInputVector(obj: ref<GameObject>, inputName: CName, value: Vector4) -> Void {
    let evt: ref<AnimInputSetterVector> = new AnimInputSetterVector();
    evt.key = inputName;
    evt.value = value;
    obj.QueueEvent(evt);
  }

  public final static func SetInputVectorToReplicate(obj: ref<GameObject>, inputName: CName, value: Vector4) -> Void {
    AnimationControllerComponent.SetInputVector(obj, inputName, value);
    obj.ReplicateInputVector(obj, inputName, value);
  }

  public final static func SetUsesSleepMode(obj: ref<GameObject>, state: Bool) -> Void {
    let evt: ref<AnimInputSetterUsesSleepMode> = new AnimInputSetterUsesSleepMode();
    evt.value = state;
    obj.QueueEvent(evt);
  }

  public final static func SetAnimWrapperWeight(obj: ref<GameObject>, key: CName, value: Float) -> Void {
    let evt: ref<AnimWrapperWeightSetter>;
    let item: ref<ItemObject>;
    if !IsNameValid(key) {
      return;
    };
    evt = new AnimWrapperWeightSetter();
    evt.key = key;
    evt.value = value;
    obj.QueueEvent(evt);
    item = obj as ItemObject;
    if IsDefined(item) {
      item.QueueEventToChildItems(evt);
    };
  }

  public final static func SetAnimWrapperWeightOnOwnerAndItems(owner: ref<GameObject>, key: CName, value: Float) -> Void {
    let item: ref<ItemObject>;
    AnimationControllerComponent.SetAnimWrapperWeight(owner, key, value);
    item = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponRight");
    if IsDefined(item) {
      AnimationControllerComponent.SetAnimWrapperWeight(item, key, value);
    };
    item = GameInstance.GetTransactionSystem(owner.GetGame()).GetItemInSlot(owner, t"AttachmentSlots.WeaponLeft");
    if IsDefined(item) {
      AnimationControllerComponent.SetAnimWrapperWeight(item, key, value);
    };
  }
}
