// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseECSPlayerController.h"
#include "BaseECSCharacter.h"
#include "BaseECSPawn.h"
#include "BaseECSActor.h"
#include "Components/InputComponent.h"
#include "Engine/World.h"
#include "Kismet/GameplayStatics.h"

ABaseECSPlayerController::ABaseECSPlayerController()
{
	PrimaryActorTick.bCanEverTick = true;
	
	// Create the capability manager component
	CapabilityManager = CreateDefaultSubobject<UCapabilityManagerComponent>(TEXT("CapabilityManager"));
	
	// Disable auto-ticking on the component since we'll manually tick it
	if (CapabilityManager)
	{
		CapabilityManager->SetComponentTickEnabled(false);
	}
}

void ABaseECSPlayerController::PostInitializeComponents()
{
	Super::PostInitializeComponents();
	
	// Initialize capabilities early
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}

void ABaseECSPlayerController::BeginPlay()
{
	Super::BeginPlay();
	
	// Additional capability initialization if needed
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}

void ABaseECSPlayerController::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	// Manual tick capabilities if enabled
	if (bManualCapabilityTicking && CapabilityManager)
	{
		CapabilityManager->ManualTick(DeltaTime);
	}
}

void ABaseECSPlayerController::SetupInputComponent()
{
	Super::SetupInputComponent();

	// Add player controller-specific input bindings here
	// Individual capabilities can also bind to input if needed
}

ABaseECSPawn* ABaseECSPlayerController::GetECSPawn() const
{
	// Cast the possessed pawn to our ECS type - returns nullptr if not an ECS pawn
	return Cast<ABaseECSPawn>(GetPawn());
}

ABaseECSCharacter* ABaseECSPlayerController::GetECSCharacter() const
{
	// Cast the possessed pawn to our ECS Character type - returns nullptr if not an ECS character
	return Cast<ABaseECSCharacter>(GetPawn());
}

TArray<ABaseECSActor*> ABaseECSPlayerController::GetNearbyECSActors(float Radius) const
{
	TArray<ABaseECSActor*> NearbyECSActors;
	
	if (UWorld* World = GetWorld())
	{
		// Use the possessed pawn's location, or a default location as fallback
		FVector SearchLocation = FVector::ZeroVector;
		if (APawn* ControlledPawn = GetPawn())
		{
			SearchLocation = ControlledPawn->GetActorLocation();
		}
		else
		{
			// Controllers don't have accessible location functions, so use world origin as fallback
			SearchLocation = FVector::ZeroVector;
		}
		
		// Get all ECS actors within radius
		TArray<AActor*> AllActors;
		UGameplayStatics::GetAllActorsOfClass(World, ABaseECSActor::StaticClass(), AllActors);
		
		for (AActor* Actor : AllActors)
		{
			if (FVector::Dist(Actor->GetActorLocation(), SearchLocation) <= Radius)
			{
				if (ABaseECSActor* ECSActor = Cast<ABaseECSActor>(Actor))
				{
					NearbyECSActors.Add(ECSActor);
				}
			}
		}
	}
	
	return NearbyECSActors;
}

void ABaseECSPlayerController::PossessECSPawn(ABaseECSPawn* ECSPawn)
{
	if (IsValid(ECSPawn))
	{
		Possess(ECSPawn);
	}
}

void ABaseECSPlayerController::PossessECSCharacter(ABaseECSCharacter* ECSCharacter)
{
	if (IsValid(ECSCharacter))
	{
		Possess(ECSCharacter);
	}
}