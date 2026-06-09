{{/*
Expand the name of the chart.
*/}}
{{- define "strimzi-cluster.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "strimzi-cluster.fullname" -}}
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
{{- define "strimzi-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "strimzi-cluster.labels" -}}
app.kubernetes.io/name: {{ include "strimzi-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ include "strimzi-cluster.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Strimzi CRD API version.
Use "kafka.strimzi.io/v1beta2" for Strimzi <= 0.51 and "kafka.strimzi.io/v1" for Strimzi >= 1.0.
The v1 API is served from 0.49 onwards; v1beta2 is removed in 1.0.
*/}}
{{- define "strimzi-cluster.apiVersion" -}}
{{- .Values.strimzi.apiVersion | default "kafka.strimzi.io/v1" -}}
{{- end }}

{{/*
Name of the cluster being deployed
*/}}
{{- define "strimzi-cluster.clusterName" -}}
{{ .Values.cluster.name | default (include "strimzi-cluster.fullname" .) }}
{{- end }}
