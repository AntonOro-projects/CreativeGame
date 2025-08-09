// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Pawn.h"
#include "Components/CapabilityManagerComponent.h"
#include "ECSInterface.h"

#include "BaseECSPawn.generated.h"

/**
 * Base ECS Pawn class that manages components and capabilities using the CapabilityManagerComponent.
 * This class provides ECS-like functionality where capabilities provide behavior
 * and components provide data storage, built on top of Unreal's Pawn system.
 */
UCLASS(BlueprintType, Blueprintable)
class CREATIVEGAME_API ABaseECSPawn : public APawn, public IECSInterface
{
	GENERATED_BODY()

public:
	ABaseECSPawn();

	virtual void Tick(float DeltaTime) override;

	// IECSInterface implementation
	virtual UCapabilityManagerComponent* GetCapabilityManager() const override { return CapabilityManager; }

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

protected:
	virtual void BeginPlay() override;

	// The core ECS functionality component
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "ECS", meta = (AllowPrivateAccess = "true"))
	UCapabilityManagerComponent* CapabilityManager;

	// Control whether this actor manually ticks capabilities or lets the component handle it
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS")
	bool bManualCapabilityTicking = true;
};