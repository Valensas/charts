{{/*
Render a Deployment for a component.
Expects: dict "root" $ "component" "<name>"
*/}}
{{- define "paranoyak-ai.deployment" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $values := index $root.Values $component -}}
{{- $ctx := dict "root" $root "component" $component -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "paranoyak-ai.component.fullname" $ctx }}
  labels:
    {{- include "paranoyak-ai.component.labels" $ctx | nindent 4 }}
spec:
  {{- if not $values.autoscaling.enabled }}
  replicas: {{ $values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "paranoyak-ai.component.selectorLabels" $ctx | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ toYaml $root.Values.config | sha256sum }}
        {{- with $values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- include "paranoyak-ai.component.labels" $ctx | nindent 8 }}
        {{- with $values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with $root.Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "paranoyak-ai.component.serviceAccountName" $ctx }}
      {{- with $values.podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ $component }}
          {{- with $values.securityContext }}
          securityContext:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          image: {{ include "paranoyak-ai.image" $ctx | quote }}
          imagePullPolicy: {{ $values.image.pullPolicy }}
          {{- if and $values.service (or (not (hasKey $values.service "enabled")) $values.service.enabled) }}
          ports:
            - name: http
              protocol: TCP
              containerPort: {{ $root.Values.config.spring.containerPort }}
            {{- if hasKey $values.service.ports "management" }}
            - name: http-management
              protocol: TCP
              containerPort: {{ $root.Values.config.spring.managementPort }}
            {{- end }}
          {{- end }}
          {{- with $values.env }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          envFrom:
            - configMapRef:
                name: {{ include "paranoyak-ai.fullname" $root }}-config
            - secretRef:
                name: {{ include "paranoyak-ai.fullname" $root }}-secret
            {{- with $values.envFrom }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- with $values.livenessProbe }}
          livenessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $values.readinessProbe }}
          readinessProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $values.startupProbe }}
          startupProbe:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $values.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $values.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
      {{- with $values.volumes }}
      volumes:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if $values.affinity }}
      affinity: {{- include "common.tplvalues.render" (dict "value" $values.affinity "context" $root) | nindent 8 }}
      {{- else }}
      affinity:
        podAffinity: {{- include "common.affinities.pods" (dict "type" $values.podAffinityPreset "component" $component "context" $root) | nindent 10 }}
        podAntiAffinity: {{- include "common.affinities.pods" (dict "type" $values.podAntiAffinityPreset "component" $component "context" $root) | nindent 10 }}
        nodeAffinity: {{- include "common.affinities.nodes" (dict "type" $values.nodeAffinityPreset.type "key" $values.nodeAffinityPreset.key "values" $values.nodeAffinityPreset.values) | nindent 10 }}
      {{- end }}
      {{- with $values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}

{{/*
Render a Service for a component.
Expects: dict "root" $ "component" "<name>"
*/}}
{{- define "paranoyak-ai.service" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $values := index $root.Values $component -}}
{{- $ctx := dict "root" $root "component" $component -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "paranoyak-ai.component.fullname" $ctx }}
  labels:
    {{- include "paranoyak-ai.component.labels" $ctx | nindent 4 }}
spec:
  type: {{ $values.service.type }}
  ports:
    - port: {{ $values.service.ports.http }}
      targetPort: http
      protocol: TCP
      name: http
    {{- if hasKey $values.service.ports "management" }}
    - port: {{ $values.service.ports.management }}
      targetPort: http-management
      protocol: TCP
      name: http-management
    {{- end }}
  selector:
    {{- include "paranoyak-ai.component.selectorLabels" $ctx | nindent 4 }}
{{- end }}

{{/*
Render an HPA for a component.
Expects: dict "root" $ "component" "<name>"
*/}}
{{- define "paranoyak-ai.hpa" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $values := index $root.Values $component -}}
{{- $ctx := dict "root" $root "component" $component -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "paranoyak-ai.component.fullname" $ctx }}
  labels:
    {{- include "paranoyak-ai.component.labels" $ctx | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "paranoyak-ai.component.fullname" $ctx }}
  minReplicas: {{ $values.autoscaling.minReplicas }}
  maxReplicas: {{ $values.autoscaling.maxReplicas }}
  metrics:
    {{- with $values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ . }}
    {{- end }}
    {{- with $values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ . }}
    {{- end }}
{{- end }}

{{/*
Render a ServiceAccount for a component.
Expects: dict "root" $ "component" "<name>"
*/}}
{{- define "paranoyak-ai.serviceAccount" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $values := index $root.Values $component -}}
{{- $ctx := dict "root" $root "component" $component -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "paranoyak-ai.component.serviceAccountName" $ctx }}
  labels:
    {{- include "paranoyak-ai.component.labels" $ctx | nindent 4 }}
  {{- with $values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
automountServiceAccountToken: {{ $values.serviceAccount.automount }}
{{- end }}

{{/*
Render a PodMonitor for a component.
Expects: dict "root" $ "component" "<name>"
*/}}
{{- define "paranoyak-ai.podMonitor" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $values := index $root.Values $component -}}
{{- $ctx := dict "root" $root "component" $component -}}
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ include "paranoyak-ai.component.fullname" $ctx }}
  labels:
    {{- include "paranoyak-ai.component.labels" $ctx | nindent 4 }}
    {{- with $values.podMonitor.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $values.podMonitor.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  selector:
    matchLabels:
      {{- include "paranoyak-ai.component.selectorLabels" $ctx | nindent 6 }}
  podMetricsEndpoints:
    - port: {{ $values.podMonitor.port | quote }}
      scheme: http
      {{- with $values.podMonitor.path }}
      path: {{ . | quote }}
      {{- end }}
      {{- with $values.podMonitor.interval }}
      interval: {{ . | quote }}
      {{- end }}
      {{- with $values.podMonitor.scrapeTimeout }}
      scrapeTimeout: {{ . | quote }}
      {{- end }}
      {{- with $values.podMonitor.relabelings }}
      relabelings:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $values.podMonitor.metricRelabelings }}
      metricRelabelings:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}

{{/*
Render an Ingress for a component.
Expects: dict "root" $ "component" "<name>"
*/}}
{{- define "paranoyak-ai.ingress" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $values := index $root.Values $component -}}
{{- $ctx := dict "root" $root "component" $component -}}
{{- $fullName := include "paranoyak-ai.component.fullname" $ctx -}}
{{- $svcPort := $values.service.ports.http -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "paranoyak-ai.component.labels" $ctx | nindent 4 }}
  {{- with $values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with $values.ingress.className }}
  ingressClassName: {{ . }}
  {{- end }}
  {{- if $values.ingress.tls }}
  tls:
    {{- range $values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range $values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            {{- with .pathType }}
            pathType: {{ . }}
            {{- end }}
            backend:
              service:
                name: {{ $fullName }}
                port:
                  number: {{ $svcPort }}
          {{- end }}
    {{- end }}
{{- end }}

{{/*
Render an HTTPRoute for a component.
Expects: dict "root" $ "component" "<name>"
*/}}
{{- define "paranoyak-ai.httpRoute" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $values := index $root.Values $component -}}
{{- $ctx := dict "root" $root "component" $component -}}
{{- $fullName := include "paranoyak-ai.component.fullname" $ctx -}}
{{- $svcPort := $values.service.ports.http -}}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "paranoyak-ai.component.labels" $ctx | nindent 4 }}
  {{- with $values.httpRoute.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  parentRefs:
    {{- with $values.httpRoute.parentRefs }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $values.httpRoute.hostnames }}
  hostnames:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    {{- range $values.httpRoute.rules }}
    {{- with .matches }}
    - matches:
      {{- toYaml . | nindent 8 }}
    {{- end }}
    {{- with .filters }}
      filters:
      {{- toYaml . | nindent 8 }}
    {{- end }}
      backendRefs:
        - name: {{ $fullName }}
          port: {{ $svcPort }}
          weight: 1
    {{- end }}
{{- end }}

{{/*
Resolve a component's container image as "<registry>/<repository>:<tag>".
Registry comes from component.image.registry, falling back to global.registry.
Empty registry yields a bare "<repository>:<tag>".
Expects: dict "root" $ "component" "<name>"
*/}}
{{- define "paranoyak-ai.image" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $values := index $root.Values $component -}}
{{- $registry := $values.image.registry | default $root.Values.global.registry -}}
{{- $repository := $values.image.repository -}}
{{- $tag := $values.image.tag | default $root.Chart.AppVersion -}}
{{- if $registry -}}
{{ printf "%s/%s:%s" $registry $repository $tag }}
{{- else -}}
{{ printf "%s:%s" $repository $tag }}
{{- end -}}
{{- end }}

{{/*
Render a PodDisruptionBudget for a component.
Expects: dict "root" $ "component" "<name>"
*/}}
{{- define "paranoyak-ai.pdb" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $values := index $root.Values $component -}}
{{- $ctx := dict "root" $root "component" $component -}}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "paranoyak-ai.component.fullname" $ctx }}
  labels:
    {{- include "paranoyak-ai.component.labels" $ctx | nindent 4 }}
spec:
  {{- with $values.pdb.minAvailable }}
  minAvailable: {{ . }}
  {{- end }}
  {{- if not $values.pdb.minAvailable }}
  maxUnavailable: {{ $values.pdb.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "paranoyak-ai.component.selectorLabels" $ctx | nindent 6 }}
{{- end }}
