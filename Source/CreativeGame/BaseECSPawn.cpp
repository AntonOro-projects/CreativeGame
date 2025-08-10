// Fill out your copyright notice in the Description page of Project Settings.

#include "BaseECSPawn.h"
#include "BaseECSPlayerController.h"
#include "BaseECSActor.h"
#include "BaseECSCharacter.h"
#include "Engine/World.h"
#include "Kismet/GameplayStatics.h"

ABaseECSPawn::ABaseECSPawn()
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

void ABaseECSPawn::BeginPlay()
{
	Super::BeginPlay();
	
	// Initialize capabilities through the manager
	if (CapabilityManager)
	{
		CapabilityManager->UpdateCapabilityStates();
	}
}

void ABaseECSPawn::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	// Manual tick capabilities if enabled
	if (bManualCapabilityTicking && CapabilityManager)
	{
		CapabilityManager->ManualTick(DeltaTime);
	}
}

ABaseECSPlayerController* ABaseECSPawn::GetECSController() const
{
	// Cast the controller to our ECS type - returns nullptr if not an ECS controller
	return Cast<ABaseECSPlayerController>(GetController());
}

TArray<ABaseECSActor*> ABaseECSPawn::GetNearbyECSActors(float Radius) const
{
	TArray<ABaseECSActor*> NearbyECSActors;
	
	if (UWorld* World = GetWorld())
	{
		TArray<AActor*> AllActors;
		UGameplayStatics::GetAllActorsOfClass(World, ABaseECSActor::StaticClass(), AllActors);
		
		const FVector MyLocation = GetActorLocation();
		
		for (AActor* Actor : AllActors)
		{
			if (Actor != this && FVector::Dist(Actor->GetActorLocation(), MyLocation) <= Radius)
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

TArray<ABaseECSPawn*> ABaseECSPawn::GetNearbyECSPawns(float Radius) const
{
	TArray<ABaseECSPawn*> NearbyECSPawns;
	
	if (UWorld* World = GetWorld())
	{
		TArray<AActor*> AllPawns;
		UGameplayStatics::GetAllActorsOfClass(World, ABaseECSPawn::StaticClass(), AllPawns);
		
		const FVector MyLocation = GetActorLocation();
		
		for (AActor* Actor : AllPawns)
		{
			if (Actor != this && FVector::Dist(Actor->GetActorLocation(), MyLocation) <= Radius)
			{
				if (ABaseECSPawn* ECSPawn = Cast<ABaseECSPawn>(Actor))
				{
					NearbyECSPawns.Add(ECSPawn);
				}
			}
		}
	}
	
	return NearbyECSPawns;
}

TArray<ABaseECSCharacter*> ABaseECSPawn::GetNearbyECSCharacters(float Radius) const
{
	TArray<ABaseECSCharacter*> NearbyECSCharacters;
	
	if (UWorld* World = GetWorld())
	{
		TArray<AActor*> AllCharacters;
		UGameplayStatics::GetAllActorsOfClass(World, ABaseECSCharacter::StaticClass(), AllCharacters);
		
		const FVector MyLocation = GetActorLocation();
		
		for (AActor* Actor : AllCharacters)
		{
			if (Actor != this && FVector::Dist(Actor->GetActorLocation(), MyLocation) <= Radius)
			{
				if (ABaseECSCharacter* ECSCharacter = Cast<ABaseECSCharacter>(Actor))
				{
					NearbyECSCharacters.Add(ECSCharacter);
				}
			}
		}
	}
	
	return NearbyECSCharacters;
}

ABaseECSActor* ABaseECSPawn::GetClosestECSActor(TSubclassOf<ABaseECSActor> ActorClass) const
{
	if (!ActorClass)
	{
		return nullptr;
	}
	
	ABaseECSActor* ClosestActor = nullptr;
	float ClosestDistance = FLT_MAX;
	
	if (UWorld* World = GetWorld())
	{
		TArray<AActor*> AllActors;
		UGameplayStatics::GetAllActorsOfClass(World, ActorClass, AllActors);
		
		const FVector MyLocation = GetActorLocation();
		
		for (AActor* Actor : AllActors)
		{
			if (Actor != this)
			{
				float Distance = FVector::Dist(Actor->GetActorLocation(), MyLocation);
				if (Distance < ClosestDistance)
				{
					if (ABaseECSActor* ECSActor = Cast<ABaseECSActor>(Actor))
					{
						ClosestDistance = Distance;
						ClosestActor = ECSActor;
					}
				}
			}
		}
	}
	
	return ClosestActor;
}