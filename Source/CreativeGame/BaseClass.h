// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Components/CapabilityManagerComponent.h"

#include "BaseClass.generated.h"

/**
 * Base actor class that manages components and capabilities using the CapabilityManagerComponent.
 * This class provides the ECS-like functionality where capabilities provide behavior
 * and components provide data storage.
 */
UCLASS(BlueprintType, Blueprintable)
class CREATIVEGAME_API ABaseECSActor : public AActor
{
	GENERATED_BODY()

public:
	ABaseECSActor();

	virtual void Tick(float DeltaTime) override;

	// Capability management - delegates to CapabilityManager
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
	TArray<UBaseCapability*> GetAllCapabilities() const;

	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	TArray<UBaseCapability*> GetActiveCapabilities() const;

	// Component management
	UFUNCTION(BlueprintCallable, Category = "Components")
	void RemoveComponent(UActorComponent* Component);

	// Force capability state updates
	UFUNCTION(BlueprintCallable, Category = "Capabilities")
	void UpdateCapabilityStates();

	// Get the capability manager component
	UFUNCTION(BlueprintPure, Category = "Capabilities")
	UCapabilityManagerComponent* GetCapabilityManager() const { return CapabilityManager; }

protected:
	virtual void BeginPlay() override;

	// The core ECS functionality component
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "ECS", meta = (AllowPrivateAccess = "true"))
	UCapabilityManagerComponent* CapabilityManager;

	// Control whether this actor manually ticks capabilities or lets the component handle it
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS")
	bool bManualCapabilityTicking = true;
};
