// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "Capabilities/BaseCapability.h"

#include "CapabilityManagerComponent.generated.h"

/**
 * Capability Manager Component that handles all ECS capability logic.
 * This component can be added to any Actor to provide capability management functionality.
 * This eliminates code duplication across Actor, Pawn, Character, and PlayerController classes.
 */
UCLASS(BlueprintType, Blueprintable, meta = (BlueprintSpawnableComponent))
class CREATIVEGAME_API UCapabilityManagerComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	UCapabilityManagerComponent();

	virtual void BeginPlay() override;
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

	// Capability management
	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	UBaseCapability* AddCapability(TSubclassOf<UBaseCapability> CapabilityClass);

	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	void AddCapabilityInstance(UBaseCapability* Capability);

	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	void RemoveCapability(UBaseCapability* Capability);

	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	UBaseCapability* GetCapability(TSubclassOf<UBaseCapability> CapabilityClass) const;

	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	TArray<UBaseCapability*> GetCapabilities(TSubclassOf<UBaseCapability> CapabilityClass) const;

	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	TArray<UBaseCapability*> GetAllCapabilities() const { return Capabilities; }

	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	TArray<UBaseCapability*> GetActiveCapabilities() const { return ActiveCapabilities; }

	// Component management
	UFUNCTION(BlueprintCallable, Category = "Components")
	void RemoveActorComponent(UActorComponent* Component);

	// Force capability state updates
	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	void UpdateCapabilityStates();

	// Manual tick for when owner doesn't want auto-ticking
	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	void ManualTick(float DeltaTime);

private:
	// Internal capability management
	void UpdateCapabilityActivation(UBaseCapability* Capability);
	void ActivateCapability(UBaseCapability* Capability);
	void DeactivateCapability(UBaseCapability* Capability);

	UPROPERTY()
	TArray<UBaseCapability*> Capabilities;

	UPROPERTY()
	TArray<UBaseCapability*> ActiveCapabilities;

	// Performance optimization - avoid checking every capability every frame
	UPROPERTY(EditAnywhere, Category = "Performance")
	float CapabilityUpdateFrequency = 0.1f; // Check capability states 10 times per second

	UPROPERTY(EditAnywhere, Category = "Performance")
	bool bAutoTick = true; // Whether this component should auto-tick or rely on manual ticking

	float LastCapabilityUpdateTime = 0.0f;
};