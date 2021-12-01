
public static func GetAnimOptions(opt playReversed: Bool, opt executionDelay: Float, opt loopType: inkanimLoopType, opt loopCounter: Uint32, opt loopInfinite: Bool, opt fromMarker: CName, opt toMarker: CName, opt oneSegment: Bool) -> inkAnimOptions {
  let animOptions: inkAnimOptions;
  animOptions.playReversed = playReversed;
  animOptions.executionDelay = executionDelay;
  animOptions.loopType = loopType;
  animOptions.loopCounter = loopCounter;
  animOptions.loopInfinite = loopInfinite;
  animOptions.fromMarker = fromMarker;
  animOptions.toMarker = toMarker;
  animOptions.oneSegment = oneSegment;
  return animOptions;
}

public static func GetAnimOptionsInfiniteLoop(loopType: inkanimLoopType) -> inkAnimOptions {
  let animOptions: inkAnimOptions;
  animOptions.loopType = loopType;
  animOptions.loopInfinite = true;
  return animOptions;
}

public static func GetAnimOptionsInfiniteLoopFinish() -> inkAnimOptions {
  let animOptions: inkAnimOptions;
  animOptions.loopType = IntEnum(0l);
  animOptions.loopInfinite = false;
  return animOptions;
}

public class WidgetAnimationManager extends IScriptable {

  private let m_animations: array<SWidgetAnimationData>;

  public final func Initialize(animations: array<SWidgetAnimationData>) -> Void {
    this.m_animations = animations;
  }

  public final const func GetAnimations() -> array<SWidgetAnimationData> {
    return this.m_animations;
  }

  public final func UpdateAnimationsList(animName: CName, updateData: ref<PlaybackOptionsUpdateData>) -> Void {
    let animationData: SWidgetAnimationData;
    if !IsDefined(updateData) {
      return;
    };
    if !this.HasAnimation(animName) {
      animationData.m_animationName = animName;
      animationData.m_playbackOptions = updateData.m_playbackOptions;
      ArrayPush(this.m_animations, animationData);
    };
  }

  public final const func HasAnimation(animName: CName) -> Bool {
    let i: Int32 = 0;
    while i < ArraySize(this.m_animations) {
      if Equals(this.m_animations[i].m_animationName, animName) {
        return true;
      };
      i += 1;
    };
    return false;
  }

  public final func CleanAllAnimationsChachedData() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_animations) {
      if this.m_animations[i].m_animProxy != null {
        this.UnregisterAllCallbacks(this.m_animations[i]);
      };
      i += 1;
    };
  }

  public final func TriggerAnimations(owner: ref<inkLogicController>) -> Void {
    let currentProxy: ref<inkAnimProxy>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_animations) {
      if !IsNameValid(this.m_animations[i].m_animationName) {
      } else {
        if this.m_animations[i].m_animProxy == null || !this.m_animations[i].m_lockWhenActive || this.m_animations[i].m_animProxy.IsFinished() || !this.m_animations[i].m_animProxy.IsPaused() && !this.m_animations[i].m_animProxy.IsPlaying() {
          if this.m_animations[i].m_animProxy != null {
            this.UnregisterAllCallbacks(this.m_animations[i]);
          };
          currentProxy = owner.PlayLibraryAnimation(this.m_animations[i].m_animationName, this.m_animations[i].m_playbackOptions);
          this.m_animations[i].m_animProxy = currentProxy;
          this.RegisterAllCallbacks(owner, this.m_animations[i]);
        };
      };
      i += 1;
    };
  }

  public final func TriggerAnimations(owner: ref<inkGameController>) -> Void {
    let currentProxy: ref<inkAnimProxy>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_animations) {
      if !IsNameValid(this.m_animations[i].m_animationName) {
      } else {
        if this.m_animations[i].m_animProxy == null || !this.m_animations[i].m_lockWhenActive || this.m_animations[i].m_animProxy.IsFinished() || !this.m_animations[i].m_animProxy.IsPaused() && !this.m_animations[i].m_animProxy.IsPlaying() {
          if this.m_animations[i].m_animProxy != null {
            this.UnregisterAllCallbacks(this.m_animations[i]);
          };
          currentProxy = owner.PlayLibraryAnimation(this.m_animations[i].m_animationName, this.m_animations[i].m_playbackOptions);
          this.m_animations[i].m_animProxy = currentProxy;
          this.RegisterAllCallbacks(owner, this.m_animations[i]);
        };
      };
      i += 1;
    };
  }

  public final func TriggerAnimationByName(owner: ref<inkLogicController>, animName: CName, playbackOption: EInkAnimationPlaybackOption, opt targetWidget: ref<inkWidget>, opt playbackOptionsOverrideData: ref<PlaybackOptionsUpdateData>) -> Void {
    let animData: SWidgetAnimationData;
    let currentProxy: ref<inkAnimProxy>;
    let playbackOptionsData: inkAnimOptions;
    let i: Int32 = 0;
    while i < ArraySize(this.m_animations) {
      if !IsNameValid(this.m_animations[i].m_animationName) {
      } else {
        if Equals(this.m_animations[i].m_animationName, animName) {
          if Equals(playbackOption, EInkAnimationPlaybackOption.PLAY) {
            if this.m_animations[i].m_animProxy == null || !this.m_animations[i].m_lockWhenActive || this.m_animations[i].m_animProxy.IsFinished() || !this.m_animations[i].m_animProxy.IsPaused() && !this.m_animations[i].m_animProxy.IsPlaying() {
              if IsDefined(playbackOptionsOverrideData) {
                playbackOptionsData = playbackOptionsOverrideData.m_playbackOptions;
              } else {
                playbackOptionsData = this.m_animations[i].m_playbackOptions;
              };
              if this.m_animations[i].m_animProxy != null {
                this.ResolveActiveAnimDataPlaybackState(this.m_animations[i], EInkAnimationPlaybackOption.STOP);
              };
              if IsDefined(targetWidget) {
                currentProxy = owner.PlayLibraryAnimationOnAutoSelectedTargets(this.m_animations[i].m_animationName, targetWidget, playbackOptionsData);
              } else {
                currentProxy = owner.PlayLibraryAnimation(this.m_animations[i].m_animationName, playbackOptionsData);
              };
              this.m_animations[i].m_animProxy = currentProxy;
              this.RegisterAllCallbacks(owner, this.m_animations[i]);
            };
          } else {
            if this.m_animations[i].m_animProxy != null {
              animData = this.m_animations[i];
              if IsDefined(playbackOptionsOverrideData) {
                animData.m_playbackOptions = playbackOptionsOverrideData.m_playbackOptions;
              };
              this.ResolveActiveAnimDataPlaybackState(animData, playbackOption);
            };
          };
        } else {
          i += 1;
        };
      };
    };
  }

  public final func TriggerAnimationByName(owner: ref<inkGameController>, animName: CName, playbackOption: EInkAnimationPlaybackOption, opt targetWidget: ref<inkWidget>, opt playbackOptionsOverrideData: ref<PlaybackOptionsUpdateData>) -> Void {
    let animData: SWidgetAnimationData;
    let currentProxy: ref<inkAnimProxy>;
    let playbackOptionsData: inkAnimOptions;
    let i: Int32 = 0;
    while i < ArraySize(this.m_animations) {
      if !IsNameValid(this.m_animations[i].m_animationName) {
      } else {
        if Equals(this.m_animations[i].m_animationName, animName) {
          if Equals(playbackOption, EInkAnimationPlaybackOption.PLAY) {
            if this.m_animations[i].m_animProxy == null || !this.m_animations[i].m_lockWhenActive || this.m_animations[i].m_animProxy.IsFinished() || !this.m_animations[i].m_animProxy.IsPaused() && !this.m_animations[i].m_animProxy.IsPlaying() {
              if IsDefined(playbackOptionsOverrideData) {
                playbackOptionsData = playbackOptionsOverrideData.m_playbackOptions;
              } else {
                playbackOptionsData = this.m_animations[i].m_playbackOptions;
              };
              if this.m_animations[i].m_animProxy != null {
                this.ResolveActiveAnimDataPlaybackState(this.m_animations[i], EInkAnimationPlaybackOption.STOP);
              };
              if IsDefined(targetWidget) {
                currentProxy = owner.PlayLibraryAnimationOnAutoSelectedTargets(this.m_animations[i].m_animationName, targetWidget, playbackOptionsData);
              } else {
                currentProxy = owner.PlayLibraryAnimation(this.m_animations[i].m_animationName, playbackOptionsData);
              };
              this.m_animations[i].m_animProxy = currentProxy;
              this.RegisterAllCallbacks(owner, this.m_animations[i]);
            };
          } else {
            if this.m_animations[i].m_animProxy != null {
              animData = this.m_animations[i];
              if IsDefined(playbackOptionsOverrideData) {
                animData.m_playbackOptions = playbackOptionsOverrideData.m_playbackOptions;
              };
              this.ResolveActiveAnimDataPlaybackState(animData, playbackOption);
            };
          };
        } else {
          i += 1;
        };
      };
    };
  }

  private final func ResolveActiveAnimDataPlaybackState(animData: SWidgetAnimationData, requestedState: EInkAnimationPlaybackOption) -> Void {
    if animData.m_animProxy == null {
      return;
    };
    if Equals(requestedState, EInkAnimationPlaybackOption.STOP) {
      animData.m_animProxy.Stop(false);
      this.UnregisterAllCallbacks(animData);
    } else {
      if Equals(requestedState, EInkAnimationPlaybackOption.PAUSE) {
        animData.m_animProxy.Pause();
      } else {
        if Equals(requestedState, EInkAnimationPlaybackOption.RESUME) {
          animData.m_animProxy.Resume();
        } else {
          if Equals(requestedState, EInkAnimationPlaybackOption.CONTINUE) {
            animData.m_animProxy.Continue(animData.m_playbackOptions);
          } else {
            if Equals(requestedState, EInkAnimationPlaybackOption.GO_TO_START) {
              animData.m_animProxy.GotoStartAndStop(false);
              this.UnregisterAllCallbacks(animData);
            } else {
              if Equals(requestedState, EInkAnimationPlaybackOption.GO_TO_END) {
                animData.m_animProxy.GotoEndAndStop(false);
                this.UnregisterAllCallbacks(animData);
              };
            };
          };
        };
      };
    };
  }

  public final func UnregisterAllCallbacks(animData: SWidgetAnimationData) -> Void {
    if animData.m_animProxy != null {
      if IsNameValid(animData.m_onFinish) {
        animData.m_animProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);
      };
      if IsNameValid(animData.m_onStart) {
        animData.m_animProxy.UnregisterFromAllCallbacks(inkanimEventType.OnStart);
      };
      if IsNameValid(animData.m_onPasue) {
        animData.m_animProxy.UnregisterFromAllCallbacks(inkanimEventType.OnPause);
      };
      if IsNameValid(animData.m_onResume) {
        animData.m_animProxy.UnregisterFromAllCallbacks(inkanimEventType.OnResume);
      };
      if IsNameValid(animData.m_onStartLoop) {
        animData.m_animProxy.UnregisterFromAllCallbacks(inkanimEventType.OnStartLoop);
      };
      if IsNameValid(animData.m_onEndLoop) {
        animData.m_animProxy.UnregisterFromAllCallbacks(inkanimEventType.OnEndLoop);
      };
    };
    this.CleanProxyData(animData);
  }

  public final func RegisterAllCallbacks(owner: ref<IScriptable>, animData: SWidgetAnimationData) -> Void {
    if animData.m_animProxy != null {
      if IsNameValid(animData.m_onFinish) {
        animData.m_animProxy.RegisterToCallback(inkanimEventType.OnFinish, owner, animData.m_onFinish);
      };
      if IsNameValid(animData.m_onStart) {
        animData.m_animProxy.RegisterToCallback(inkanimEventType.OnStart, owner, animData.m_onStart);
      };
      if IsNameValid(animData.m_onPasue) {
        animData.m_animProxy.RegisterToCallback(inkanimEventType.OnPause, owner, animData.m_onPasue);
      };
      if IsNameValid(animData.m_onResume) {
        animData.m_animProxy.RegisterToCallback(inkanimEventType.OnResume, owner, animData.m_onResume);
      };
      if IsNameValid(animData.m_onStartLoop) {
        animData.m_animProxy.RegisterToCallback(inkanimEventType.OnStartLoop, owner, animData.m_onStartLoop);
      };
      if IsNameValid(animData.m_onEndLoop) {
        animData.m_animProxy.RegisterToCallback(inkanimEventType.OnEndLoop, owner, animData.m_onEndLoop);
      };
    };
  }

  public final func ResolveCallback(owner: ref<IScriptable>, animProxy: ref<inkAnimProxy>, eventType: inkanimEventType) -> Void {
    let i: Int32;
    if animProxy == null {
      return;
    };
    i = 0;
    while i < ArraySize(this.m_animations) {
      if this.m_animations[i].m_animProxy == animProxy {
        if Equals(eventType, inkanimEventType.OnFinish) {
          this.UnregisterAllCallbacks(this.m_animations[i]);
          this.m_animations[i].m_animProxy = null;
        } else {
          animProxy.UnregisterFromCallback(eventType, owner, this.GetAnimationCallbackName(this.m_animations[i], eventType));
        };
      };
      i += 1;
    };
  }

  private final func GetAnimationCallbackName(animData: SWidgetAnimationData, eventType: inkanimEventType) -> CName {
    let returnValue: CName;
    if Equals(eventType, inkanimEventType.OnStart) {
      animData.m_onStart;
    } else {
      if Equals(eventType, inkanimEventType.OnFinish) {
        animData.m_onFinish;
      } else {
        if Equals(eventType, inkanimEventType.OnPause) {
          animData.m_onPasue;
        } else {
          if Equals(eventType, inkanimEventType.OnResume) {
            animData.m_onResume;
          } else {
            if Equals(eventType, inkanimEventType.OnStartLoop) {
              animData.m_onStartLoop;
            } else {
              if Equals(eventType, inkanimEventType.OnEndLoop) {
                animData.m_onEndLoop;
              };
            };
          };
        };
      };
    };
    return returnValue;
  }

  private final func CleanProxyData(animData: SWidgetAnimationData) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_animations) {
      if this.m_animations[i].m_animProxy == animData.m_animProxy {
        this.m_animations[i].m_animProxy = null;
      } else {
        i += 1;
      };
    };
  }
}
