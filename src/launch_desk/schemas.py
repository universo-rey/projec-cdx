from __future__ import annotations

from datetime import date
from typing import Literal

from pydantic import BaseModel, Field


class LaunchDeskRequest(BaseModel):
    product_brief: str = Field(..., min_length=10, description="Rough product or feature launch brief.")
    audience: str = Field(..., min_length=2, description="Primary audience for the launch.")
    launch_date: date | None = Field(default=None, description="Target launch date, if known.")
    constraints: list[str] = Field(default_factory=list, description="Hard limits, approvals, or launch constraints.")
    assets: list[str] = Field(default_factory=list, description="Existing launch assets and collateral.")
    desired_channels: list[str] = Field(
        default_factory=lambda: ["Slack", "Email", "Release notes"],
        description="Channels that need launch copy.",
    )


class LaunchPlanStep(BaseModel):
    priority: int = Field(..., ge=1, le=10, description="Priority where 1 is highest.")
    owner: str = Field(..., description="Suggested owner or owning function.")
    action: str = Field(..., description="Concrete launch action.")
    reason: str = Field(..., description="Why this action matters.")
    due: str | None = Field(default=None, description="Suggested timing or due date.")


class LaunchRiskItem(BaseModel):
    risk: str = Field(..., description="Launch risk or failure mode.")
    severity: Literal["low", "medium", "high", "critical"] = Field(..., description="Impact if the risk happens.")
    likelihood: Literal["low", "medium", "high"] = Field(..., description="Likelihood before mitigation.")
    mitigation: str = Field(..., description="Practical mitigation or fallback.")
    owner: str = Field(..., description="Owner responsible for reducing the risk.")


class OwnerChecklistItem(BaseModel):
    owner: str = Field(..., description="Owner or team.")
    checklist: list[str] = Field(default_factory=list, description="Concrete checklist items for this owner.")


class CopySuggestion(BaseModel):
    channel: str = Field(..., description="Launch communication channel.")
    audience: str = Field(..., description="Audience for this copy.")
    tone: str = Field(..., description="Suggested tone.")
    draft: str = Field(..., description="Draft launch copy.")


class FollowUpQuestion(BaseModel):
    question: str = Field(..., description="Question needed to improve or unblock the plan.")
    why_it_matters: str = Field(..., description="Reason this answer matters.")
    blocking: bool = Field(default=True, description="Whether the missing answer blocks launch planning.")


class ReadinessRubricItem(BaseModel):
    dimension: str = Field(..., description="Readiness dimension.")
    status: Literal["ready", "partial", "blocked"] = Field(..., description="Status for this dimension.")
    notes: str = Field(..., description="Evidence or gap for this dimension.")


class ReadinessSummary(BaseModel):
    score: int = Field(..., ge=0, le=100, description="Overall readiness score.")
    verdict: Literal["go", "go_with_risks", "hold"] = Field(..., description="Launch decision recommendation.")
    top_gaps: list[str] = Field(default_factory=list, description="Most important remaining gaps.")
    rubric: list[ReadinessRubricItem] = Field(default_factory=list, description="Readiness rubric details.")


class LaunchDeskReport(BaseModel):
    title: str = Field(..., description="Short title for the launch plan.")
    summary: str = Field(..., description="Executive summary of the launch plan.")
    assumptions: list[str] = Field(default_factory=list, description="Assumptions made from incomplete inputs.")
    follow_up_questions: list[FollowUpQuestion] = Field(default_factory=list, description="Questions for missing launch details.")
    prioritized_plan: list[LaunchPlanStep] = Field(default_factory=list, description="Prioritized actionable launch plan.")
    risk_register: list[LaunchRiskItem] = Field(default_factory=list, description="Launch risk register.")
    owner_checklist: list[OwnerChecklistItem] = Field(default_factory=list, description="Owner-by-owner launch checklist.")
    launch_copy_suggestions: list[CopySuggestion] = Field(default_factory=list, description="Channel-specific launch copy drafts.")
    readiness: ReadinessSummary = Field(..., description="Readiness score, verdict, and rubric.")
    next_action: str = Field(..., description="Single most important next action.")


class LaunchDeskRunRecord(BaseModel):
    request_id: str
    created_at: str
    model: str
    request: LaunchDeskRequest
    report: LaunchDeskReport


class LaunchDeskHistoryItem(BaseModel):
    request_id: str
    created_at: str
    model: str
    title: str
    summary: str
    score: int
    verdict: Literal["go", "go_with_risks", "hold"]
    audience: str
    launch_date: str | None = None


class LaunchDeskHistoryResponse(BaseModel):
    items: list[LaunchDeskHistoryItem] = Field(default_factory=list)
