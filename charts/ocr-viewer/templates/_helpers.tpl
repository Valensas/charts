{{- define "ocr-viewer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ocr-viewer.fullname" -}}
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

{{- define "ocr-viewer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ocr-viewer.labels" -}}
helm.sh/chart: {{ include "ocr-viewer.chart" . }}
{{ include "ocr-viewer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "ocr-viewer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ocr-viewer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "ocr-viewer.allowedHosts" -}}
{{- $hosts := list }}
{{- if .Values.ingress.enabled }}
{{- range .Values.ingress.hosts }}
{{- $hosts = append $hosts .host }}
{{- end }}
{{- end }}
{{- if .Values.httpRoute.enabled }}
{{- range .Values.httpRoute.hostnames }}
{{- $hosts = append $hosts . }}
{{- end }}
{{- end }}
{{- range .Values.extraAllowedHosts }}
{{- $hosts = append $hosts . }}
{{- end }}
{{- join "," (uniq (compact $hosts)) }}
{{- end }}
