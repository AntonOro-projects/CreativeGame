// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Components/CapabilityManagerComponent.h"

#include "BaseECSActor.generated.h"

/**
 * Base ECS Actor class that manages components and capabilities using the CapabilityManagerComponent.
 * Access capabilities directly through GetCapabilityManager() instead of wrapper functions.
 * This eliminates delegation boilerplate and provides direct component access.
 */
UCLASS(BlueprintType, Blueprintable)
class CREATIVEGAME_API ABaseECSActor : public AActor
{
	GENERATED_BODY()

public:
	ABaseECSActor();

	virtual void Tick(float DeltaTime) override;

	// Direct access to capability manager - this is all you need!
	UFUNCTION(BlueprintPure, Category = "ECS")
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
