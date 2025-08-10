// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Components/CapabilityManagerComponent.h"

#include "BaseECSActor.generated.h"

// Forward declarations for ECS types
class ABaseECSCharacter;
class ABaseECSPawn;
class ABaseECSPlayerController;

/**
 * Base ECS Actor class that manages components and capabilities using the CapabilityManagerComponent.
 * Access capabilities directly through GetCapabilityManager() instead of wrapper functions.
 * This eliminates delegation boilerplate and provides direct component access.
 *
 * Provides type-safe access to other ECS classes to ensure we're always working within the ECS ecosystem.
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

	// Helper function to find nearby ECS Actors
	UFUNCTION(BlueprintCallable, Category = "ECS")
	TArray<ABaseECSActor*> GetNearbyECSActors(float Radius) const;

	// Helper function to find ECS Pawns in range
	UFUNCTION(BlueprintCallable, Category = "ECS")
	TArray<ABaseECSPawn*> GetNearbyECSPawns(float Radius) const;

	// Helper function to find ECS Characters in range
	UFUNCTION(BlueprintCallable, Category = "ECS")
	TArray<ABaseECSCharacter*> GetNearbyECSCharacters(float Radius) const;

	// Helper function to find ECS PlayerControllers in the world
	UFUNCTION(BlueprintCallable, Category = "ECS")
	TArray<ABaseECSPlayerController*> GetECSPlayerControllers() const;

	// Find the closest ECS Actor of a specific type
	UFUNCTION(BlueprintCallable, Category = "ECS")
	ABaseECSActor* GetClosestECSActor(TSubclassOf<ABaseECSActor> ActorClass) const;

protected:
	virtual void BeginPlay() override;

	// The core ECS functionality component
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "ECS", meta = (AllowPrivateAccess = "true"))
	UCapabilityManagerComponent* CapabilityManager;

	// Control whether this actor manually ticks capabilities or lets the component handle it
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "ECS")
	bool bManualCapabilityTicking = true;
};