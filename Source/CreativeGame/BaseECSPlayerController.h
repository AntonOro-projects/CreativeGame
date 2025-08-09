// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "ECSInterface.h"
#include "ECSMacros.h"

#include "BaseECSPlayerController.generated.h"

/**
 * Base ECS Player Controller class that manages components and capabilities using the CapabilityManagerComponent.
 * This class provides ECS-like functionality where capabilities provide behavior
 * and components provide data storage, built on top of Unreal's PlayerController system.
 */
UCLASS(BlueprintType, Blueprintable)
class CREATIVEGAME_API ABaseECSPlayerController : public APlayerController, public IECSInterface
{
	GENERATED_BODY()

public:
	ABaseECSPlayerController();

	virtual void Tick(float DeltaTime) override;

	// IECSInterface implementation
	virtual UCapabilityManagerComponent* GetCapabilityManager() const override { return CapabilityManager; }

	// ECS capability management functions
	DECLARE_ECS_CAPABILITY_FUNCTIONS()

protected:
	virtual void BeginPlay() override;
	
	// Called when the player controller is initialized
	virtual void PostInitializeComponents() override;

	// Called to bind functionality to input
	virtual void SetupInputComponent() override;

	// ECS component and properties
	DECLARE_ECS_COMPONENT()
};