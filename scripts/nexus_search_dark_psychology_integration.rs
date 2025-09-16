// Nexus-Search Dark Psychology Protection Integration
// File: src/dark_psychology_protection.rs

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use tokio::time::{Duration, Instant};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StarterUserProfile {
    pub user_id: String,
    pub vulnerability_score: f64,
    pub protection_level: ProtectionLevel,
    pub communication_patterns: CommunicationProfile,
    pub trigger_sensitivity: TriggerSensitivity,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ProtectionLevel {
    Maximum,    // New users, high vulnerability
    High,       // Identified patterns of targeting
    Standard,   // Regular protection
    Minimal,    // Established safe users
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommunicationProfile {
    pub processing_speed: ProcessingSpeed,
    pub sensory_sensitivity: Vec<SensoryTrigger>,
    pub social_interaction_style: SocialStyle,
    pub information_processing: CognitiveStyle,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ProcessingSpeed {
    Slow,       // Extra time needed
    Variable,   // ADHD patterns
    Standard,   // Typical processing
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SensoryTrigger {
    VisualOverload,
    AudioSensitivity,
    InformationFlood,
    RapidContextSwitch,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DarkPatternDetection {
    pub pattern_type: DarkPatternType,
    pub confidence: f64,
    pub target_vulnerability: Vec<String>,
    pub detected_at: Instant,
    pub mitigation_applied: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum DarkPatternType {
    Gaslighting,
    CognitiveOverload,
    SocialExclusion,
    PersonalityMasking,
    WeaponizedIncompetence,
    SensoryTargeting,
    // From your bureaucratic analysis
    DelayTactic,
    DenialPattern,
    DefenseDeflection,
    DeferralRedirect,
}

pub struct NexusSearchProtectionEngine {
    search_engine: NexusSearchCore,
    pattern_database: HashMap<String, DarkPatternDetection>,
    user_profiles: HashMap<String, StarterUserProfile>,
    protection_rules: Vec<ProtectionRule>,
}

impl NexusSearchProtectionEngine {
    pub fn new() -> Self {
        Self {
            search_engine: NexusSearchCore::new(),
            pattern_database: HashMap::new(),
            user_profiles: HashMap::new(),
            protection_rules: Self::initialize_protection_rules(),
        }
    }

    /// Initialize core protection rules from your Dark Psychology Mitigation Spec
    fn initialize_protection_rules() -> Vec<ProtectionRule> {
        vec![
            // Gaslighting Protection
            ProtectionRule {
                pattern: DarkPatternType::Gaslighting,
                triggers: vec![
                    "you're being too sensitive",
                    "that didn't happen",
                    "you're overreacting",
                    "calm down",
                ],
                response: ProtectionResponse::ImmediateIntervention,
                vulnerability_multiplier: 2.0,
            },
            
            // Cognitive Overload Protection
            ProtectionRule {
                pattern: DarkPatternType::CognitiveOverload,
                triggers: vec![
                    "rapid_context_switch",
                    "information_flood",
                    "simultaneous_demands",
                ],
                response: ProtectionResponse::SlowDown,
                vulnerability_multiplier: 1.5,
            },

            // Bureaucratic Pattern Detection (from your 4D analysis)
            ProtectionRule {
                pattern: DarkPatternType::DelayTactic,
                triggers: vec![
                    "need more information",
                    "additional review required",
                    "please wait",
                    "processing time",
                ],
                response: ProtectionResponse::TimelineEnforcement,
                vulnerability_multiplier: 1.3,
            },

            // Social Exclusion Protection
            ProtectionRule {
                pattern: DarkPatternType::SocialExclusion,
                triggers: vec![
                    "neurotypical_only",
                    "social_complexity_barrier",
                    "indirect_exclusion",
                ],
                response: ProtectionResponse::InclusionEnforcement,
                vulnerability_multiplier: 2.5,
            },
        ]
    }

    /// Core protection function - analyzes communication for dark patterns
    pub async fn analyze_communication(
        &mut self,
        user_id: &str,
        message_content: &str,
        context: CommunicationContext,
    ) -> ProtectionResult {
        // Get user profile or create starter profile
        let user_profile = self.get_or_create_starter_profile(user_id).await;

        // Search for dark pattern indicators
        let search_results = self.search_engine.search_patterns(
            message_content,
            &self.protection_rules,
        ).await?;

        // Analyze results against user vulnerability
        let mut detections = Vec::new();
        for result in search_results {
            let vulnerability_factor = self.calculate_vulnerability_factor(
                &user_profile,
                &result.pattern_type,
            );

            if result.confidence * vulnerability_factor > 0.7 {
                detections.push(DarkPatternDetection {
                    pattern_type: result.pattern_type,
                    confidence: result.confidence * vulnerability_factor,
                    target_vulnerability: result.exploited_vulnerabilities,
                    detected_at: Instant::now(),
                    mitigation_applied: false,
                });
            }
        }

        // Apply protections
        let protections_applied = self.apply_protections(
            &user_profile,
            &detections,
            &context,
        ).await;

        ProtectionResult {
            user_id: user_id.to_string(),
            patterns_detected: detections,
            protections_applied,
            user_safety_level: self.calculate_safety_level(&user_profile, &detections),
        }
    }

    /// Creates protective profile for new users
    async fn get_or_create_starter_profile(&mut self, user_id: &str) -> StarterUserProfile {
        if let Some(profile) = self.user_profiles.get(user_id) {
            return profile.clone();
        }

        // New user - create maximum protection profile
        let starter_profile = StarterUserProfile {
            user_id: user_id.to_string(),
            vulnerability_score: 1.0, // Maximum protection for new users
            protection_level: ProtectionLevel::Maximum,
            communication_patterns: CommunicationProfile {
                processing_speed: ProcessingSpeed::Variable, // Assume accommodation needed
                sensory_sensitivity: vec![
                    SensoryTrigger::InformationFlood,
                    SensoryTrigger::RapidContextSwitch,
                ],
                social_interaction_style: SocialStyle::CautionRequired,
                information_processing: CognitiveStyle::AccommodationNeeded,
            },
            trigger_sensitivity: TriggerSensitivity::High,
        };

        self.user_profiles.insert(user_id.to_string(), starter_profile.clone());
        starter_profile
    }

    /// Calculate how vulnerable a user is to specific dark patterns
    fn calculate_vulnerability_factor(
        &self,
        user_profile: &StarterUserProfile,
        pattern_type: &DarkPatternType,
    ) -> f64 {
        let base_vulnerability = user_profile.vulnerability_score;
        
        let pattern_specific_multiplier = match pattern_type {
            DarkPatternType::Gaslighting => {
                // Higher vulnerability if user has processing differences
                if matches!(user_profile.communication_patterns.processing_speed, ProcessingSpeed::Variable) {
                    1.5
                } else {
                    1.0
                }
            },
            DarkPatternType::CognitiveOverload => {
                // Check sensory sensitivities
                if user_profile.communication_patterns.sensory_sensitivity.contains(&SensoryTrigger::InformationFlood) {
                    2.0
                } else {
                    1.0
                }
            },
            DarkPatternType::SocialExclusion => {
                // Higher vulnerability for those needing social accommodation
                if matches!(user_profile.communication_patterns.social_interaction_style, SocialStyle::CautionRequired) {
                    1.8
                } else {
                    1.0
                }
            },
            // Bureaucratic patterns affect everyone, but disabled users more
            DarkPatternType::DelayTactic | DarkPatternType::DenialPattern => {
                base_vulnerability * 1.3
            },
            _ => 1.0,
        };

        (base_vulnerability * pattern_specific_multiplier).min(3.0) // Cap at 3x
    }

    /// Apply protective interventions
    async fn apply_protections(
        &mut self,
        user_profile: &StarterUserProfile,
        detections: &[DarkPatternDetection],
        context: &CommunicationContext,
    ) -> Vec<ProtectionMeasure> {
        let mut protections = Vec::new();

        for detection in detections {
            let protection = match detection.pattern_type {
                DarkPatternType::Gaslighting => {
                    ProtectionMeasure::RealityAnchor {
                        message: "This appears to be gaslighting. Your perception is valid.".to_string(),
                        evidence_provided: true,
                        support_offered: true,
                    }
                },
                
                DarkPatternType::CognitiveOverload => {
                    ProtectionMeasure::ProcessingSupport {
                        slowdown_applied: true,
                        information_chunked: true,
                        timeout_provided: Duration::from_secs(300), // 5 minute processing break
                    }
                },

                DarkPatternType::SocialExclusion => {
                    ProtectionMeasure::InclusionSupport {
                        alternative_participation_offered: true,
                        accommodation_provided: true,
                        advocacy_activated: true,
                    }
                },

                // Your bureaucratic patterns
                DarkPatternType::DelayTactic => {
                    ProtectionMeasure::TimelineEnforcement {
                        legal_timeline_referenced: true,
                        escalation_path_provided: true,
                        documentation_started: true,
                    }
                },

                DarkPatternType::DenialPattern => {
                    ProtectionMeasure::EvidenceSupport {
                        documentation_assistance: true,
                        witness_protection: true,
                        legal_framework_cited: true,
                    }
                },

                _ => ProtectionMeasure::GeneralSupport,
            };

            protections.push(protection);
        }

        protections
    }
}

// Supporting types for the protection system
#[derive(Debug, Clone)]
pub struct ProtectionRule {
    pub pattern: DarkPatternType,
    pub triggers: Vec<&'static str>,
    pub response: ProtectionResponse,
    pub vulnerability_multiplier: f64,
}

#[derive(Debug, Clone)]
pub enum ProtectionResponse {
    ImmediateIntervention,
    SlowDown,
    TimelineEnforcement,
    InclusionEnforcement,
    EvidenceSupport,
}

#[derive(Debug, Clone)]
pub enum ProtectionMeasure {
    RealityAnchor {
        message: String,
        evidence_provided: bool,
        support_offered: bool,
    },
    ProcessingSupport {
        slowdown_applied: bool,
        information_chunked: bool,
        timeout_provided: Duration,
    },
    InclusionSupport {
        alternative_participation_offered: bool,
        accommodation_provided: bool,
        advocacy_activated: bool,
    },
    TimelineEnforcement {
        legal_timeline_referenced: bool,
        escalation_path_provided: bool,
        documentation_started: bool,
    },
    EvidenceSupport {
        documentation_assistance: bool,
        witness_protection: bool,
        legal_framework_cited: bool,
    },
    GeneralSupport,
}

#[derive(Debug)]
pub struct ProtectionResult {
    pub user_id: String,
    pub patterns_detected: Vec<DarkPatternDetection>,
    pub protections_applied: Vec<ProtectionMeasure>,
    pub user_safety_level: SafetyLevel,
}

#[derive(Debug)]
pub enum SafetyLevel {
    Safe,
    Caution,
    AtRisk,
    ImmediateDanger,
}

// Nexus Search Core - stub for integration with your actual search engine
pub struct NexusSearchCore {
    // Integration with your nsc.exe functionality
}

impl NexusSearchCore {
    pub fn new() -> Self {
        Self {}
    }

    pub async fn search_patterns(
        &self,
        content: &str,
        rules: &[ProtectionRule],
    ) -> Result<Vec<PatternSearchResult>, SearchError> {
        // This would integrate with your actual nexus-search implementation
        // For now, returning mock structure
        Ok(vec![])
    }
}

#[derive(Debug)]
pub struct PatternSearchResult {
    pub pattern_type: DarkPatternType,
    pub confidence: f64,
    pub exploited_vulnerabilities: Vec<String>,
}

// Additional supporting enums
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SocialStyle {
    CautionRequired,
    Standard,
    Independent,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum CognitiveStyle {
    AccommodationNeeded,
    StandardProcessing,
    HighCapacity,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum TriggerSensitivity {
    High,
    Medium,
    Low,
}

#[derive(Debug, Clone)]
pub struct CommunicationContext {
    pub platform: String,
    pub participants: Vec<String>,
    pub is_public: bool,
    pub has_authority_figures: bool,
}

#[derive(Debug)]
pub enum SearchError {
    PatternNotFound,
    EngineError(String),
    ConfigurationError,
}

// CLI Integration for nsc.exe
pub async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut protection_engine = NexusSearchProtectionEngine::new();

    // Example usage
    let result = protection_engine.analyze_communication(
        "starter_user_123",
        "You're being too sensitive about this housing issue. That didn't really happen the way you remember.",
        CommunicationContext {
            platform: "obinexus_chat".to_string(),
            participants: vec!["starter_user_123".to_string(), "responder".to_string()],
            is_public: false,
            has_authority_figures: true,
        },
    ).await;

    println!("Protection Analysis Result: {:?}", result);
    Ok(())
}