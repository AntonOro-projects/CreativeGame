#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "BaseCapability.generated.h"

/**
 * Base capability class that provides behavior to actors.
 * Capabilities can be activated/deactivated and are ticked manually by their owner.
 * They should not tick on their own - instead use TickCapability.
 * 
 * This class leverages UActorComponent's built-in activation system:
 * - Use IsActive() to check if the capability is active
 * - Use SetActive() to activate/deactivate the capability
 * - Override Activate() and Deactivate() for custom logic
 */
UCLASS(BlueprintType, Blueprintable, meta = (BlueprintSpawnableComponent))
class CREATIVEGAME_API UBaseCapability : public UActorComponent
{
    GENERATED_BODY()

public:
    UBaseCapability();

    // State management - override these for custom activation logic
    UFUNCTION(BlueprintCallable, BlueprintNativeEvent, Category = "Capabilities")
    bool ShouldBeActive();

    UFUNCTION(BlueprintCallable, BlueprintNativeEvent, Category = "Capabilities")
    bool ShouldDeactivate();

    UFUNCTION(BlueprintCallable, BlueprintNativeEvent, Category = "Capabilities")
    bool ShouldActivate();

    // Override UActorComponent's activation methods for capability-specific logic
    virtual void Activate(bool bReset = false) override;
    virtual void Deactivate() override;

    // Manual ticking - called by owner when capability is active
    UFUNCTION(BlueprintCallable, BlueprintNativeEvent, Category = "Capabilities")
    void TickCapability(float DeltaTime);

    // Priority system for capability ordering
    UFUNCTION(BlueprintPure, Category = "Capabilities")
    int32 GetPriority() const { return Priority; }

    UFUNCTION(BlueprintCallable, Category = "Capabilities")
    void SetPriority(int32 NewPriority) { Priority = NewPriority; }

protected:
    virtual void BeginPlay() override;

    // Called when capability is activated - override for custom behavior
    UFUNCTION(BlueprintNativeEvent, Category = "Capabilities")
    void OnCapabilityActivated();

    // Called when capability is deactivated - override for custom behavior
    UFUNCTION(BlueprintNativeEvent, Category = "Capabilities")
    void OnCapabilityDeactivated();

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Capability Settings")
    int32 Priority = 0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Capability Settings")
    bool bStartActive = false;
};
