{{/*
Expand the name of the chart.
*/}}
{{- define "paranoyak-ai.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "paranoyak-ai.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "paranoyak-ai.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Chart-level common labels (shared resources, not tied to a component).
*/}}
{{- define "paranoyak-ai.labels" -}}
helm.sh/chart: {{ include "paranoyak-ai.chart" . }}
app.kubernetes.io/name: {{ include "paranoyak-ai.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Component fullname: <release-fullname>-<component>
Expects: dict "root" $ "component" "frontend"
*/}}
{{- define "paranoyak-ai.component.fullname" -}}
{{- printf "%s-%s" (include "paranoyak-ai.fullname" .root) .component | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Component selector labels.
Expects: dict "root" $ "component" "frontend"
*/}}
{{- define "paranoyak-ai.component.selectorLabels" -}}
app.kubernetes.io/name: {{ include "paranoyak-ai.name" .root }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Component common labels.
Expects: dict "root" $ "component" "frontend"
*/}}
{{- define "paranoyak-ai.component.labels" -}}
{{ include "paranoyak-ai.labels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Component service account name.
Expects: dict "root" $ "component" "frontend"
*/}}
{{- define "paranoyak-ai.component.serviceAccountName" -}}
{{- $values := index .root.Values .component }}
{{- if $values.serviceAccount.create }}
{{- default (include "paranoyak-ai.component.fullname" .) $values.serviceAccount.name }}
{{- else }}
{{- default "default" $values.serviceAccount.name }}
{{- end }}
{{- end }}
