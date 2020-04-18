// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WorldSpaceTrees/HDRP_TreeLeafSwitcher"
{
	/*CustomNodeUI:HDPBR*/
    Properties
    {
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_DesaturateTranslucency("DesaturateTranslucency", Range( 0 , 1)) = 0.4
		_SelfIllum("SelfIllum", Range( 0 , 1)) = 0
		_DarknessOnSundown("DarknessOnSundown", Range( 0 , 1)) = 0.75
		[Toggle]_WorldSpaceOffset("WorldSpaceOffset?", Float) = 1
		[Toggle]_SwitchColumn("SwitchColumn", Float) = 0
		[Toggle]_SwitchRow("SwitchRow", Float) = 0
		_Gloss("Gloss", Range( 0 , 1)) = 0.2
		_Albedo_MaskA("Albedo_Mask(A)", 2D) = "white" {}
		_TranslucencyMap("TranslucencyMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_MotionPowerWeightMask("MotionPowerWeightMask", 2D) = "white" {}
		_MotionSpeed("MotionSpeed", Range( 0 , 10)) = 1
		_MotionRange("MotionRange", Range( 0 , 10)) = 0.5
		[ASEDiffusionProfile(_Diffusion)]_Diffusion_asset("Diffusion", Vector) = ( 228889264007084710000000000000000000000, 0.000000000000000000000000012389357880079404, 0.00000000000000000000000000000000000076932702684439582, 0.00018220426863990724 )
		[HideInInspector]_Diffusion("Diffusion", Float) = 3.5648174285888672
		_Translucency("Translucency", Range( 0 , 2)) = 2

    }

    SubShader
    {
		LOD 0

		
        Tags { "RenderPipeline"="HDRenderPipeline" "RenderType"="TreeTransparentCutout" "Queue"="Geometry" }
        
		Cull Off
		Blend One Zero
		ZTest LEqual
		ZWrite On
		ZClip [_ZClip]

		HLSLINCLUDE
		#pragma target 4.5
		#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
		#pragma multi_compile_instancing
		#pragma instancing_options renderinglayer
		#pragma multi_compile _ LOD_FADE_CROSSFADE

		struct GlobalSurfaceDescription
		{
			//Standard
			float3 Albedo;
			float3 Normal;
			float3 Specular;
			float Metallic;
			float3 Emission;
			float Smoothness;
			float Occlusion;
			float Alpha;
			float AlphaClipThreshold;
			float CoatMask;
			//SSS
			float DiffusionProfile;
			float SubsurfaceMask;
			//Transmission
			float Thickness;
			// Anisotropic
			float3 TangentWS;
			float Anisotropy; 
			//Iridescence
			float IridescenceThickness;
			float IridescenceMask;
			// Transparency
			float IndexOfRefraction;
			float3 TransmittanceColor;
			float TransmittanceAbsorptionDistance;
			float TransmittanceMask;
		};

		struct AlphaSurfaceDescription
		{
			float Alpha;
			float AlphaClipThreshold;
		};

		ENDHLSL
		
        Pass
        {
			
            Name "GBuffer"
            Tags { "LightMode"="GBuffer" }    
			Stencil
			{
				Ref 2
				WriteMask 51
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

     
            HLSLPROGRAM
        	#define _MATERIAL_FEATURE_TRANSMISSION 1
        	#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
        	#define _NORMALMAP 1
        	#define _ALPHATEST_ON 1
        	#define ASE_SRP_VERSION 70108

        	//#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag
			
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            #define SHADERPASS SHADERPASS_GBUFFER
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
			#pragma multi_compile _ LIGHT_LAYERS
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

            struct AttributesMesh 
			{
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct PackedVaryingsMeshToPS 
			{
                float4 positionCS : SV_Position;
                float3 interp00 : TEXCOORD0;
                float3 interp01 : TEXCOORD1;
                float4 interp02 : TEXCOORD2;
                float4 interp03 : TEXCOORD3;
				float4 interp04 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
            };
        
			sampler2D _MotionPowerWeightMask;
			float4x4 unity_CameraProjection;
			float4x4 unity_CameraInvProjection;
			float4x4 unity_WorldToCamera;
			float4x4 unity_CameraToWorld;
			sampler2D _Albedo_MaskA;
			sampler2D _NormalMap;
			sampler2D _TranslucencyMap;
			CBUFFER_START( UnityPerMaterial )
			float _MotionSpeed;
			float _MotionRange;
			float _WorldSpaceOffset;
			float _SwitchRow;
			float _SwitchColumn;
			float _DarknessOnSundown;
			float _DesaturateTranslucency;
			float _SelfIllum;
			float _Gloss;
			float _Diffusion;
			float _Translucency;
			CBUFFER_END

			
			
			void BuildSurfaceData ( FragInputs fragInputs, GlobalSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData )
			{
				ZERO_INITIALIZE ( SurfaceData, surfaceData );

				float3 normalTS = float3( 0.0f, 0.0f, 1.0f );
				normalTS = surfaceDescription.Normal;
				float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS ( fragInputs, normalTS, surfaceData.normalWS ,doubleSidedConstants);

				surfaceData.ambientOcclusion = 1.0f;

				surfaceData.baseColor = surfaceDescription.Albedo;
				surfaceData.perceptualSmoothness = surfaceDescription.Smoothness;
				surfaceData.ambientOcclusion = surfaceDescription.Occlusion;

				surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;

				#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
				surfaceData.specularColor = surfaceDescription.Specular;
				#else
				surfaceData.metallic = surfaceDescription.Metallic;
				#endif

				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceData.diffusionProfileHash = asuint(surfaceDescription.DiffusionProfile);
				#endif

				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
				surfaceData.subsurfaceMask = surfaceDescription.SubsurfaceMask;
				#else
				surfaceData.subsurfaceMask = 1.0f;
				#endif

				#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
				surfaceData.thickness = surfaceDescription.Thickness;
				#endif

				surfaceData.tangentWS = normalize( fragInputs.tangentToWorld[ 0 ].xyz );
				surfaceData.tangentWS = Orthonormalize( surfaceData.tangentWS, surfaceData.normalWS );

				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
				surfaceData.anisotropy = surfaceDescription.Anisotropy;

				#else
				surfaceData.anisotropy = 0;
				#endif

				#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
				surfaceData.coatMask = surfaceDescription.CoatMask;
				#else
				surfaceData.coatMask = 0.0f;
				#endif

				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
				surfaceData.iridescenceThickness = surfaceDescription.IridescenceThickness;
				surfaceData.iridescenceMask = surfaceDescription.IridescenceMask;
				#else
				surfaceData.iridescenceThickness = 0.0;
				surfaceData.iridescenceMask = 1.0;
				#endif

				//ASE CUSTOM TAG
				#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceData.ior = surfaceDescription.IndexOfRefraction;
				surfaceData.transmittanceColor = surfaceDescription.TransmittanceColor;
				surfaceData.atDistance = surfaceDescription.TransmittanceAbsorptionDistance;
				surfaceData.transmittanceMask = surfaceDescription.TransmittanceMask;
				#else
				surfaceData.ior = 1.0;
				surfaceData.transmittanceColor = float3( 1.0, 1.0, 1.0 );
				surfaceData.atDistance = 1000000.0;
				surfaceData.transmittanceMask = 0.0;
				#endif

				surfaceData.specularOcclusion = 1.0;

				#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO( V, bentNormalWS, surfaceData );
				#elif defined(_MASKMAP)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion( NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness( surfaceData.perceptualSmoothness ) );
				#endif
				#if HAVE_DECALS
				if( _EnableDecals )
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData( posInput, surfaceDescription.Alpha );
					ApplyDecalToSurfaceData( decalSurfaceData, surfaceData );
				}
				#endif
			}

            void GetSurfaceAndBuiltinData( GlobalSurfaceDescription surfaceDescription , FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
        
				#if _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif
				BuildSurfaceData( fragInputs, surfaceDescription, V, posInput, surfaceData );
        
                // Builtin Data
                // For back lighting we use the oposite vertex normal 
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
				builtinData.emissiveColor =             surfaceDescription.Emission;
                builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
                builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
                builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);            
            }
        
			PackedVaryingsMeshToPS Vert ( AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

				UNITY_SETUP_INSTANCE_ID ( inputMesh );
				UNITY_TRANSFER_INSTANCE_ID ( inputMesh, outputPackedVaryingsMeshToPS );

				float mulTime28 = _TimeParameters.y * _MotionSpeed;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 temp_cast_0 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
				float2 uv022 = inputMesh.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode47 = tex2Dlod( _MotionPowerWeightMask, float4( appendResult35, 0, 0.0) );
				
				outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = inputMesh.positionOS.xyz;
				#else
				float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = ( inputMesh.normalOS * ( ( sin( ( mulTime28 + ( ase_worldPos.x + ase_worldPos.z ) ) ) * _MotionRange ) * tex2DNode47.r * tex2DNode47.g * tex2DNode47.b ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS =  inputMesh.normalOS ;

				float3 positionRWS = TransformObjectToWorld ( inputMesh.positionOS.xyz );
				float3 normalWS = TransformObjectToWorldNormal ( inputMesh.normalOS );
				float4 tangentWS = float4( TransformObjectToWorldDir ( inputMesh.tangentOS.xyz ), inputMesh.tangentOS.w );
				float4 positionCS = TransformWorldToHClip ( positionRWS );

				outputPackedVaryingsMeshToPS.positionCS = positionCS;
				outputPackedVaryingsMeshToPS.interp00.xyz = positionRWS;
				outputPackedVaryingsMeshToPS.interp01.xyz = normalWS;
				outputPackedVaryingsMeshToPS.interp02.xyzw = tangentWS;
				outputPackedVaryingsMeshToPS.interp03 = inputMesh.uv1;
				outputPackedVaryingsMeshToPS.interp04 = inputMesh.uv2;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( outputPackedVaryingsMeshToPS );
				return outputPackedVaryingsMeshToPS;
			}

			void Frag ( PackedVaryingsMeshToPS packedInput, 
						OUTPUT_GBUFFER ( outGBuffer )
						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						 
						)
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( packedInput );
				FragInputs input;
				ZERO_INITIALIZE ( FragInputs, input );
				input.tangentToWorld = k_identity3x3;
				
				float3 positionRWS = packedInput.interp00.xyz;
				float3 normalWS = packedInput.interp01.xyz;
				float4 tangentWS = packedInput.interp02.xyzw;
			
				input.positionSS = packedInput.positionCS;
				input.positionRWS = positionRWS;
				input.tangentToWorld = BuildTangentToWorld ( tangentWS, normalWS );
				input.texCoord1 = packedInput.interp03;
				input.texCoord2 = packedInput.interp04;

				// input.positionSS is SV_Position
				PositionInputs posInput = GetPositionInput ( input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS );

				float3 normalizedWorldViewDir = GetWorldSpaceNormalizeViewDir ( input.positionRWS );

				SurfaceData surfaceData;
				BuiltinData builtinData;

				GlobalSurfaceDescription surfaceDescription = ( GlobalSurfaceDescription ) 0;
				float dotResult39 = dot( float3(0,1,0) , SafeNormalize(-_DirectionalLightDatas[0].forward) );
				float clampResult43 = clamp( dotResult39 , 0.0 , 1.0 );
				float3 temp_cast_0 = (clampResult43).xxx;
				float temp_output_2_0_g3 = _DarknessOnSundown;
				float temp_output_3_0_g3 = ( 1.0 - temp_output_2_0_g3 );
				float3 appendResult7_g3 = (float3(temp_output_3_0_g3 , temp_output_3_0_g3 , temp_output_3_0_g3));
				float3 temp_output_50_0 = ( ( temp_cast_0 * temp_output_2_0_g3 ) + appendResult7_g3 );
				float2 temp_cast_2 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_2 ));
				float2 uv022 = packedInput.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode37 = tex2D( _Albedo_MaskA, appendResult35 );
				
				float3 desaturateInitialColor97 = tex2DNode37.rgb;
				float desaturateDot97 = dot( desaturateInitialColor97, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar97 = lerp( desaturateInitialColor97, desaturateDot97.xxx, _DesaturateTranslucency );
				
				float3 desaturateInitialColor54 = tex2D( _TranslucencyMap, appendResult35 ).rgb;
				float desaturateDot54 = dot( desaturateInitialColor54, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar54 = lerp( desaturateInitialColor54, desaturateDot54.xxx, _DesaturateTranslucency );
				
				surfaceDescription.Albedo = ( float4( temp_output_50_0 , 0.0 ) * tex2DNode37 ).rgb;
				surfaceDescription.Normal = UnpackNormalmapRGorAG( tex2D( _NormalMap, appendResult35 ), 1.0f );
				surfaceDescription.Emission = ( desaturateVar97 * _SelfIllum );
				surfaceDescription.Specular = 0;
				surfaceDescription.Metallic = 0;
				surfaceDescription.Smoothness = _Gloss;
				surfaceDescription.Occlusion = 1;
				surfaceDescription.Alpha = tex2DNode37.a;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceDescription.CoatMask = 0;
				#endif

				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceDescription.DiffusionProfile = _Diffusion;
				#endif

				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceDescription.SubsurfaceMask = 1;
				#endif

				#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceDescription.Thickness = ( desaturateVar54 * _Translucency ).x;
				#endif

				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceDescription.Anisotropy = 0;
				#endif

				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceDescription.IridescenceThickness = 0;
				surfaceDescription.IridescenceMask = 1;
				#endif

				#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceDescription.IndexOfRefraction = 1;
				surfaceDescription.TransmittanceColor = float3( 1, 1, 1 );
				surfaceDescription.TransmittanceAbsorptionDistance = 1000000;
				surfaceDescription.TransmittanceMask = 0;
				#endif
				GetSurfaceAndBuiltinData ( surfaceDescription, input, normalizedWorldViewDir, posInput, surfaceData, builtinData );
				ENCODE_INTO_GBUFFER ( surfaceData, builtinData, posInput.positionSS, outGBuffer );
				#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
				#endif
			}

            ENDHLSL
        }
        
		
		
        Pass
        {
			
            Name "META"
            Tags { "LightMode"="Meta" }
            Cull Off
            HLSLPROGRAM
			#define _MATERIAL_FEATURE_TRANSMISSION 1
			#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
			#define _NORMALMAP 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 70108

			//#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
			#define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
			#define ATTRIBUTES_NEED_COLOR
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

			

            struct AttributesMesh 
			{
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 color : COLOR;
				
            };

            struct PackedVaryingsMeshToPS
			{
                float4 positionCS : SV_Position;
				float4 ase_texcoord : TEXCOORD0;
            };
            
			sampler2D _MotionPowerWeightMask;
			float4x4 unity_CameraProjection;
			float4x4 unity_CameraInvProjection;
			float4x4 unity_WorldToCamera;
			float4x4 unity_CameraToWorld;
			sampler2D _Albedo_MaskA;
			sampler2D _NormalMap;
			sampler2D _TranslucencyMap;
			CBUFFER_START( UnityPerMaterial )
			float _MotionSpeed;
			float _MotionRange;
			float _WorldSpaceOffset;
			float _SwitchRow;
			float _SwitchColumn;
			float _DarknessOnSundown;
			float _DesaturateTranslucency;
			float _SelfIllum;
			float _Gloss;
			float _Diffusion;
			float _Translucency;
			CBUFFER_END

			
			
			void BuildSurfaceData ( FragInputs fragInputs, GlobalSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData )
			{
				ZERO_INITIALIZE ( SurfaceData, surfaceData );

				float3 normalTS = float3( 0.0f, 0.0f, 1.0f );
				normalTS = surfaceDescription.Normal;
				float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS ( fragInputs, normalTS, surfaceData.normalWS ,doubleSidedConstants);

				surfaceData.ambientOcclusion = 1.0f;

				surfaceData.baseColor = surfaceDescription.Albedo;
				surfaceData.perceptualSmoothness = surfaceDescription.Smoothness;
				surfaceData.ambientOcclusion = surfaceDescription.Occlusion;

				surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;

				#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
				surfaceData.specularColor = surfaceDescription.Specular;
				#else
				surfaceData.metallic = surfaceDescription.Metallic;
				#endif

				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceData.diffusionProfileHash = asuint(surfaceDescription.DiffusionProfile);
				#endif

				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
				surfaceData.subsurfaceMask = surfaceDescription.SubsurfaceMask;

				#else
				surfaceData.subsurfaceMask = 1.0f;
				#endif

				#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
				surfaceData.thickness = surfaceDescription.Thickness;
				#endif

				surfaceData.tangentWS = normalize ( fragInputs.tangentToWorld[ 0 ].xyz );
				surfaceData.tangentWS = Orthonormalize ( surfaceData.tangentWS, surfaceData.normalWS );

				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
				surfaceData.anisotropy = surfaceDescription.Anisotropy;

				#else
				surfaceData.anisotropy = 0;
				#endif

				#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
				surfaceData.coatMask = surfaceDescription.CoatMask;
				#else
				surfaceData.coatMask = 0.0f;
				#endif

				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
				surfaceData.iridescenceThickness = surfaceDescription.IridescenceThickness;
				surfaceData.iridescenceMask = surfaceDescription.IridescenceMask;
				#else
				surfaceData.iridescenceThickness = 0.0;
				surfaceData.iridescenceMask = 1.0;
				#endif

				//ASE CUSTOM TAG
				#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceData.ior = surfaceDescription.IndexOfRefraction;
				surfaceData.transmittanceColor = surfaceDescription.TransmittanceColor;
				surfaceData.atDistance = surfaceDescription.TransmittanceAbsorptionDistance;
				surfaceData.transmittanceMask = surfaceDescription.TransmittanceMask;
				#else
				surfaceData.ior = 1.0;
				surfaceData.transmittanceColor = float3( 1.0, 1.0, 1.0 );
				surfaceData.atDistance = 1000000.0;
				surfaceData.transmittanceMask = 0.0;
				#endif

				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion (ClampNdotV (dot (surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness (surfaceData.perceptualSmoothness));

				#if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
				#endif

				#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO ( V, bentNormalWS, surfaceData );
				#elif defined(_MASKMAP)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion ( NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness ( surfaceData.perceptualSmoothness ) );
				#endif
			}

            void GetSurfaceAndBuiltinData( GlobalSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
				#if _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif
				BuildSurfaceData (fragInputs, surfaceDescription, V, posInput, surfaceData);
        
				// Builtin Data
                // For back lighting we use the oposite vertex normal 
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
		        builtinData.emissiveColor =             surfaceDescription.Emission;
                builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
                builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
                builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);
            }
        
           
			CBUFFER_START ( UnityMetaPass )
				bool4 unity_MetaVertexControl;
				bool4 unity_MetaFragmentControl;
			CBUFFER_END


			float unity_OneOverOutputBoost;
			float unity_MaxOutputValue;

			PackedVaryingsMeshToPS Vert ( AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

				UNITY_SETUP_INSTANCE_ID ( inputMesh );
				UNITY_TRANSFER_INSTANCE_ID ( inputMesh, outputPackedVaryingsMeshToPS );

				float mulTime28 = _TimeParameters.y * _MotionSpeed;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 temp_cast_0 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
				float2 uv022 = inputMesh.uv0 * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode47 = tex2Dlod( _MotionPowerWeightMask, float4( appendResult35, 0, 0.0) );
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.uv0;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = inputMesh.positionOS.xyz;
				#else
				float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = ( inputMesh.normalOS * ( ( sin( ( mulTime28 + ( ase_worldPos.x + ase_worldPos.z ) ) ) * _MotionRange ) * tex2DNode47.r * tex2DNode47.g * tex2DNode47.b ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS =  inputMesh.normalOS ;

				float2 uv;

				if ( unity_MetaVertexControl.x )
				{
					uv = inputMesh.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
				}
				else if ( unity_MetaVertexControl.y )
				{
					uv = inputMesh.uv2 * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				}

				outputPackedVaryingsMeshToPS.positionCS = float4( uv * 2.0 - 1.0, inputMesh.positionOS.z > 0 ? 1.0e-4 : 0.0, 1.0 );

				return outputPackedVaryingsMeshToPS;
			}

			float4 Frag ( PackedVaryingsMeshToPS packedInput  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );
				FragInputs input;
				ZERO_INITIALIZE ( FragInputs, input );
				input.tangentToWorld = k_identity3x3;
				input.positionSS = packedInput.positionCS;

				PositionInputs posInput = GetPositionInput ( input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS );

				float3 V = 0;

				SurfaceData surfaceData;
				BuiltinData builtinData;

				GlobalSurfaceDescription surfaceDescription = ( GlobalSurfaceDescription ) 0;
				float dotResult39 = dot( float3(0,1,0) , SafeNormalize(-_DirectionalLightDatas[0].forward) );
				float clampResult43 = clamp( dotResult39 , 0.0 , 1.0 );
				float3 temp_cast_0 = (clampResult43).xxx;
				float temp_output_2_0_g3 = _DarknessOnSundown;
				float temp_output_3_0_g3 = ( 1.0 - temp_output_2_0_g3 );
				float3 appendResult7_g3 = (float3(temp_output_3_0_g3 , temp_output_3_0_g3 , temp_output_3_0_g3));
				float3 temp_output_50_0 = ( ( temp_cast_0 * temp_output_2_0_g3 ) + appendResult7_g3 );
				float2 temp_cast_2 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_2 ));
				float2 uv022 = packedInput.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode37 = tex2D( _Albedo_MaskA, appendResult35 );
				
				float3 desaturateInitialColor97 = tex2DNode37.rgb;
				float desaturateDot97 = dot( desaturateInitialColor97, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar97 = lerp( desaturateInitialColor97, desaturateDot97.xxx, _DesaturateTranslucency );
				
				float3 desaturateInitialColor54 = tex2D( _TranslucencyMap, appendResult35 ).rgb;
				float desaturateDot54 = dot( desaturateInitialColor54, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar54 = lerp( desaturateInitialColor54, desaturateDot54.xxx, _DesaturateTranslucency );
				
				surfaceDescription.Albedo = ( float4( temp_output_50_0 , 0.0 ) * tex2DNode37 ).rgb;
				surfaceDescription.Normal = UnpackNormalmapRGorAG( tex2D( _NormalMap, appendResult35 ), 1.0f );
				surfaceDescription.Emission = ( desaturateVar97 * _SelfIllum );
				surfaceDescription.Specular = 0;
				surfaceDescription.Metallic = 0;
				surfaceDescription.Smoothness = _Gloss;
				surfaceDescription.Occlusion = 1;
				surfaceDescription.Alpha = tex2DNode37.a;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceDescription.CoatMask = 0;
				#endif

				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceDescription.DiffusionProfile = _Diffusion;
				#endif

				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceDescription.SubsurfaceMask = 1;
				#endif

				#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceDescription.Thickness = ( desaturateVar54 * _Translucency ).x;
				#endif

				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceDescription.Anisotropy = 0;
				#endif

				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceDescription.IridescenceThickness = 0;
				surfaceDescription.IridescenceMask = 1;
				#endif

				#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceDescription.IndexOfRefraction = 1;
				surfaceDescription.TransmittanceColor = float3( 1, 1, 1 );
				surfaceDescription.TransmittanceAbsorptionDistance = 1000000;
				surfaceDescription.TransmittanceMask = 0;
				#endif

				GetSurfaceAndBuiltinData ( surfaceDescription, input, V, posInput, surfaceData, builtinData );

				BSDFData bsdfData = ConvertSurfaceDataToBSDFData ( input.positionSS.xy, surfaceData );

				LightTransportData lightTransportData = GetLightTransportData ( surfaceData, builtinData, bsdfData );

				float4 res = float4( 0.0, 0.0, 0.0, 1.0 );
				if ( unity_MetaFragmentControl.x )
				{
					res.rgb = clamp ( pow ( abs ( lightTransportData.diffuseColor ), saturate ( unity_OneOverOutputBoost ) ), 0, unity_MaxOutputValue );
				}

				if ( unity_MetaFragmentControl.y )
				{
					res.rgb = lightTransportData.emissiveColor;
				}

				return res;
			}
       
            ENDHLSL
        }

		
		Pass
        {
			
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
            ColorMask 0
			

            HLSLPROGRAM
			#define _MATERIAL_FEATURE_TRANSMISSION 1
			#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
			#define _NORMALMAP 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 70108

			//#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            #define SHADERPASS SHADERPASS_SHADOWS
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

			
        

            struct AttributesMesh 
			{
                float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct PackedVaryingsMeshToPS 
			{
                float4 positionCS : SV_Position;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
            };
        
			sampler2D _MotionPowerWeightMask;
			float4x4 unity_CameraProjection;
			float4x4 unity_CameraInvProjection;
			float4x4 unity_WorldToCamera;
			float4x4 unity_CameraToWorld;
			sampler2D _Albedo_MaskA;
			CBUFFER_START( UnityPerMaterial )
			float _MotionSpeed;
			float _MotionRange;
			float _WorldSpaceOffset;
			float _SwitchRow;
			float _SwitchColumn;
			float _DarknessOnSundown;
			float _DesaturateTranslucency;
			float _SelfIllum;
			float _Gloss;
			float _Diffusion;
			float _Translucency;
			CBUFFER_END

			
			
            void BuildSurfaceData(FragInputs fragInputs, AlphaSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
            {
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                surfaceData.ambientOcclusion =      1.0f;
                surfaceData.subsurfaceMask =        1.0f;
        
                surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
				#endif
				#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
				#endif
				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
				#endif
				#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
				#endif
				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
				#endif
				#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
				#endif
        
                float3 normalTS = float3(0.0f, 0.0f, 1.0f);
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
                surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);
                surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
                surfaceData.anisotropy = 0;
                surfaceData.coatMask = 0.0f;
                surfaceData.iridescenceThickness = 0.0;
                surfaceData.iridescenceMask = 1.0;
                surfaceData.ior = 1.0;
                surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
                surfaceData.atDistance = 1000000.0;
                surfaceData.transmittanceMask = 0.0;
                surfaceData.specularOcclusion = 1.0;
				#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData);
				#elif defined(_MASKMAP)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
				#endif
				#if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
				#endif
            }
        
            void GetSurfaceAndBuiltinData( AlphaSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
				#if _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif
                BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
                // Builtin Data
                // For back lighting we use the oposite vertex normal 
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
                builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
                builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
                builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);            
            }

			PackedVaryingsMeshToPS Vert( AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

				UNITY_SETUP_INSTANCE_ID ( inputMesh );
				UNITY_TRANSFER_INSTANCE_ID ( inputMesh, outputPackedVaryingsMeshToPS );

				float mulTime28 = _TimeParameters.y * _MotionSpeed;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 temp_cast_0 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
				float2 uv022 = inputMesh.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode47 = tex2Dlod( _MotionPowerWeightMask, float4( appendResult35, 0, 0.0) );
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = inputMesh.positionOS.xyz;
				#else
				float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = ( inputMesh.normalOS * ( ( sin( ( mulTime28 + ( ase_worldPos.x + ase_worldPos.z ) ) ) * _MotionRange ) * tex2DNode47.r * tex2DNode47.g * tex2DNode47.b ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS =  inputMesh.normalOS ;

				float3 positionRWS = TransformObjectToWorld ( inputMesh.positionOS.xyz );
				float4 positionCS = TransformWorldToHClip ( positionRWS );

				outputPackedVaryingsMeshToPS.positionCS = positionCS;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( outputPackedVaryingsMeshToPS );
				return outputPackedVaryingsMeshToPS;
			}

			void Frag(  PackedVaryingsMeshToPS packedInput
						#ifdef WRITE_NORMAL_BUFFER
						, out float4 outNormalBuffer : SV_Target0
							#ifdef WRITE_MSAA_DEPTH
							, out float1 depthColor : SV_Target1
							#endif
						#elif defined(WRITE_MSAA_DEPTH) // When only WRITE_MSAA_DEPTH is define and not WRITE_NORMAL_BUFFER it mean we are Unlit and only need depth, but we still have normal buffer binded
						, out float4 outNormalBuffer : SV_Target0
						, out float1 depthColor : SV_Target1
						#else
						, out float4 outColor : SV_Target0
						#endif

						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						 
						)
				{
					UNITY_SETUP_INSTANCE_ID( packedInput );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( packedInput );
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.tangentToWorld = k_identity3x3;
					input.positionSS = packedInput.positionCS;       // input.positionCS is SV_Position

					// input.positionSS is SV_Position
					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

					float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0

					SurfaceData surfaceData;
					BuiltinData builtinData;
					AlphaSurfaceDescription surfaceDescription = (AlphaSurfaceDescription)0;
					float2 temp_cast_0 = (0.0).xx;
					float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
					float ifLocalVar13 = 0;
					UNITY_BRANCH 
					if( frac( objToWorld8.x ) <= 0.5 )
					ifLocalVar13 = 0.5;
					else
					ifLocalVar13 = 1.0;
					float ifLocalVar14 = 0;
					UNITY_BRANCH 
					if( frac( objToWorld8.z ) <= 0.5 )
					ifLocalVar14 = 0.5;
					else
					ifLocalVar14 = 1.0;
					float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
					float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
					float2 uv022 = packedInput.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
					float4 tex2DNode37 = tex2D( _Albedo_MaskA, appendResult35 );
					
					surfaceDescription.Alpha = tex2DNode37.a;
					surfaceDescription.AlphaClipThreshold = 0.5;

					GetSurfaceAndBuiltinData(surfaceDescription,input, V, posInput, surfaceData, builtinData);

					#ifdef _DEPTHOFFSET_ON
					outputDepth = posInput.deviceDepth;
					#endif

					#ifdef WRITE_NORMAL_BUFFER
					EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
					#ifdef WRITE_MSAA_DEPTH
					depthColor = packedInput.positionCS.z;
					#endif
					#elif defined(WRITE_MSAA_DEPTH) 
					outNormalBuffer = float4(0.0, 0.0, 0.0, 1.0);
					depthColor = packedInput.vmesh.positionCS.z;
					#elif defined(SCENESELECTIONPASS)
					outColor = float4(_ObjectId, _PassValue, 1.0, 1.0);
					#else
					outColor = float4(0.0, 0.0, 0.0, 0.0);
					#endif
				}
            ENDHLSL
        }
		
		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

            ColorMask 0
        
            HLSLPROGRAM
			#define _MATERIAL_FEATURE_TRANSMISSION 1
			#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
			#define _NORMALMAP 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 70108

			//#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            #define SHADERPASS SHADERPASS_DEPTH_ONLY
            #define SCENESELECTIONPASS
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
			
        
			int _ObjectId;
			int _PassValue;
        
			struct AttributesMesh 
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
        
			struct PackedVaryingsMeshToPS 
			{
				float4 positionCS : SV_Position; 
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
        
			sampler2D _MotionPowerWeightMask;
			float4x4 unity_CameraProjection;
			float4x4 unity_CameraInvProjection;
			float4x4 unity_WorldToCamera;
			float4x4 unity_CameraToWorld;
			sampler2D _Albedo_MaskA;
			CBUFFER_START( UnityPerMaterial )
			float _MotionSpeed;
			float _MotionRange;
			float _WorldSpaceOffset;
			float _SwitchRow;
			float _SwitchColumn;
			float _DarknessOnSundown;
			float _DesaturateTranslucency;
			float _SelfIllum;
			float _Gloss;
			float _Diffusion;
			float _Translucency;
			CBUFFER_END

		
			                
        
			void BuildSurfaceData(FragInputs fragInputs, AlphaSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
			{
				ZERO_INITIALIZE(SurfaceData, surfaceData);
				surfaceData.ambientOcclusion =      1.0f;
				surfaceData.subsurfaceMask =        1.0f;
				surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
				#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
				#endif
				float3 normalTS =                   float3(0.0f, 0.0f, 1.0f);
				float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
				surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz); 
				surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
				surfaceData.anisotropy = 0;
				surfaceData.coatMask = 0.0f;
				surfaceData.iridescenceThickness = 0.0;
				surfaceData.iridescenceMask = 1.0;
				surfaceData.ior = 1.0;
				surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
				surfaceData.atDistance = 1000000.0;
				surfaceData.transmittanceMask = 0.0;
				surfaceData.specularOcclusion = 1.0;
				#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData);
				#elif defined(_MASKMAP)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
				#endif
				
				#if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
				#endif
			}
        
			void GetSurfaceAndBuiltinData(AlphaSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
			{
				#if _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif

				BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
				builtinData.distortion =                float2(0.0, 0.0);           
				builtinData.distortionBlur =            0.0;                        
				builtinData.depthOffset =               0.0;                        
				PostInitBuiltinData(V, posInput, surfaceData, builtinData);
			}
        
       
			PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;
					
				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);
					
				float mulTime28 = _TimeParameters.y * _MotionSpeed;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 temp_cast_0 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
				float2 uv022 = inputMesh.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode47 = tex2Dlod( _MotionPowerWeightMask, float4( appendResult35, 0, 0.0) );
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = inputMesh.positionOS.xyz;
				#else
				float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = ( inputMesh.normalOS * ( ( sin( ( mulTime28 + ( ase_worldPos.x + ase_worldPos.z ) ) ) * _MotionRange ) * tex2DNode47.r * tex2DNode47.g * tex2DNode47.b ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS =  inputMesh.normalOS ;

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
					
				outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
			
				return outputPackedVaryingsMeshToPS;
			}

			void Frag(  PackedVaryingsMeshToPS packedInput
						#ifdef WRITE_NORMAL_BUFFER
						, out float4 outNormalBuffer : SV_Target0
							#ifdef WRITE_MSAA_DEPTH
							, out float1 depthColor : SV_Target1
							#endif
						#elif defined(WRITE_MSAA_DEPTH) 
						, out float4 outNormalBuffer : SV_Target0
						, out float1 depthColor : SV_Target1
						#elif defined(SCENESELECTIONPASS)
						, out float4 outColor : SV_Target0
						#endif

						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						
					)
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );
				FragInputs input;
				ZERO_INITIALIZE(FragInputs, input);
				input.tangentToWorld = k_identity3x3;
				input.positionSS = packedInput.positionCS;
					

				// input.positionSS is SV_Position
				PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

				
				float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0
				
				SurfaceData surfaceData;
				BuiltinData builtinData;
				AlphaSurfaceDescription surfaceDescription = ( AlphaSurfaceDescription ) 0;
				float2 temp_cast_0 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
				float2 uv022 = packedInput.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode37 = tex2D( _Albedo_MaskA, appendResult35 );
				
				surfaceDescription.Alpha = tex2DNode37.a;
				surfaceDescription.AlphaClipThreshold = 0.5;
				GetSurfaceAndBuiltinData(surfaceDescription, input, V, posInput, surfaceData, builtinData);

				#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
				#endif

				#ifdef WRITE_NORMAL_BUFFER
				EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
				#ifdef WRITE_MSAA_DEPTH
				depthColor = packedInput.positionCS.z;
				#endif
				#elif defined(WRITE_MSAA_DEPTH) 
				outNormalBuffer = float4(0.0, 0.0, 0.0, 1.0);
				depthColor = packedInput.vmesh.positionCS.z;
				#elif defined(SCENESELECTIONPASS)
				outColor = float4(_ObjectId, _PassValue, 1.0, 1.0);
				#endif
			}

            ENDHLSL
        }
		
        Pass
        {
			
            Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }
			Stencil
			{
				Ref 0
				WriteMask 48
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

            
            HLSLPROGRAM
			#define _MATERIAL_FEATURE_TRANSMISSION 1
			#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
			#define _NORMALMAP 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 70108

			//#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag
        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
			#define SHADERPASS SHADERPASS_DEPTH_ONLY
			#pragma multi_compile _ WRITE_NORMAL_BUFFER
			#pragma multi_compile _ WRITE_MSAA_DEPTH

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD0
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define ATTRIBUTES_NEED_TEXCOORD2
			#define ATTRIBUTES_NEED_TEXCOORD3
			#define ATTRIBUTES_NEED_COLOR
			#define VARYINGS_NEED_POSITION_WS
			#define VARYINGS_NEED_TANGENT_TO_WORLD
			#define VARYINGS_NEED_TEXCOORD0
			#define VARYINGS_NEED_TEXCOORD1
			#define VARYINGS_NEED_TEXCOORD2
			#define VARYINGS_NEED_TEXCOORD3
			#define VARYINGS_NEED_COLOR
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
			
				
			struct AttributesMesh 
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct PackedVaryingsMeshToPS 
			{
				float4 positionCS : SV_Position;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MotionPowerWeightMask;
			float4x4 unity_CameraProjection;
			float4x4 unity_CameraInvProjection;
			float4x4 unity_WorldToCamera;
			float4x4 unity_CameraToWorld;
			sampler2D _Albedo_MaskA;
			CBUFFER_START( UnityPerMaterial )
			float _MotionSpeed;
			float _MotionRange;
			float _WorldSpaceOffset;
			float _SwitchRow;
			float _SwitchColumn;
			float _DarknessOnSundown;
			float _DesaturateTranslucency;
			float _SelfIllum;
			float _Gloss;
			float _Diffusion;
			float _Translucency;
			CBUFFER_END

				
			        
			void BuildSurfaceData(FragInputs fragInputs, AlphaSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
			{
				ZERO_INITIALIZE(SurfaceData, surfaceData);
				surfaceData.ambientOcclusion =      1.0f;
				surfaceData.subsurfaceMask =        1.0f;

				surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
				#endif
				#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
				#endif
				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
				#endif
				#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
				#endif
				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
				#endif
				#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
				#endif
				float3 normalTS =                   float3(0.0f, 0.0f, 1.0f);
				float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
				surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);    // The tangent is not normalize in tangentToWorld for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
				surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
				surfaceData.anisotropy = 0;
				surfaceData.coatMask = 0.0f;
				surfaceData.iridescenceThickness = 0.0;
				surfaceData.iridescenceMask = 1.0;
				surfaceData.ior = 1.0;
				surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
				surfaceData.atDistance = 1000000.0;
				surfaceData.transmittanceMask = 0.0;
				surfaceData.specularOcclusion = 1.0;
				#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData);
				#elif defined(_MASKMAP)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
				#endif
				#if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
				#endif
			}
        
			void GetSurfaceAndBuiltinData(AlphaSurfaceDescription surfaceDescription,FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
			{
				#if _ALPHATEST_ON
					DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif
				BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);

				builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
				builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
				builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
				PostInitBuiltinData(V, posInput, surfaceData, builtinData);
			}

			PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;
				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

				float mulTime28 = _TimeParameters.y * _MotionSpeed;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 temp_cast_0 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
				float2 uv022 = inputMesh.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode47 = tex2Dlod( _MotionPowerWeightMask, float4( appendResult35, 0, 0.0) );
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = inputMesh.positionOS.xyz;
				#else
				float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = ( inputMesh.normalOS * ( ( sin( ( mulTime28 + ( ase_worldPos.x + ase_worldPos.z ) ) ) * _MotionRange ) * tex2DNode47.r * tex2DNode47.g * tex2DNode47.b ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS =  inputMesh.normalOS ;

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
				outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( outputPackedVaryingsMeshToPS );
				return outputPackedVaryingsMeshToPS;
			}

			void Frag(  PackedVaryingsMeshToPS packedInput
						#ifdef WRITE_NORMAL_BUFFER
						, out float4 outNormalBuffer : SV_Target0
							#ifdef WRITE_MSAA_DEPTH
							, out float1 depthColor : SV_Target1
							#endif
						#elif defined(WRITE_MSAA_DEPTH) // When only WRITE_MSAA_DEPTH is define and not WRITE_NORMAL_BUFFER it mean we are Unlit and only need depth, but we still have normal buffer binded
						, out float4 outNormalBuffer : SV_Target0
						, out float1 depthColor : SV_Target1
						#else
						, out float4 outColor : SV_Target0
						#endif

						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						
					)
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( packedInput );	
				FragInputs input;
				ZERO_INITIALIZE(FragInputs, input);
				input.tangentToWorld = k_identity3x3;
				input.positionSS = packedInput.positionCS;
				
				PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

				float3 V = float3(1.0, 1.0, 1.0);

				SurfaceData surfaceData;
				BuiltinData builtinData;
				AlphaSurfaceDescription surfaceDescription = ( AlphaSurfaceDescription ) 0;
				float2 temp_cast_0 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
				float2 uv022 = packedInput.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode37 = tex2D( _Albedo_MaskA, appendResult35 );
				
				surfaceDescription.Alpha = tex2DNode37.a;
				surfaceDescription.AlphaClipThreshold = 0.5;

				GetSurfaceAndBuiltinData(surfaceDescription, input, V, posInput, surfaceData, builtinData);

				#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
				#endif

				#ifdef WRITE_NORMAL_BUFFER
				EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
				#ifdef WRITE_MSAA_DEPTH
				depthColor = packedInput.positionCS.z;
				#endif
				#elif defined(WRITE_MSAA_DEPTH)
				outNormalBuffer = float4(0.0, 0.0, 0.0, 1.0);
				depthColor = packedInput.positionCS.z;
				#elif defined(SCENESELECTIONPASS)
				outColor = float4(_ObjectId, _PassValue, 1.0, 1.0);
				#else
				outColor = float4(0.0, 0.0, 0.0, 0.0);
				#endif
			}
        
            ENDHLSL
        }

		
        Pass
        {
			
            Name "Motion Vectors"
            Tags { "LightMode"="MotionVectors" }
        
			Stencil
			{
				Ref 128
				WriteMask 176
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

             
            HLSLPROGRAM
			#define _MATERIAL_FEATURE_TRANSMISSION 1
			#define _MATERIAL_FEATURE_SPECULAR_COLOR 1
			#define _NORMALMAP 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 70108

			//#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag
        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
			#define SHADERPASS SHADERPASS_MOTION_VECTORS
			#pragma multi_compile _ WRITE_NORMAL_BUFFER
            #pragma multi_compile _ WRITE_MSAA_DEPTH

            #define VARYINGS_NEED_POSITION_WS
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
			
        
			struct AttributesMesh
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
        
			struct VaryingsMeshToPS 
			{
				float4 positionCS : SV_Position;
				float3 positionRWS;
			};

			struct AttributesPass
			{
				float3 previousPositionOS : TEXCOORD4;
			};

			struct VaryingsPassToPS
			{
				float4 positionCS;
				float4 previousPositionCS;
			};

			#define VARYINGS_NEED_PASS

			struct VaryingsToPS
			{
				VaryingsMeshToPS vmesh;
				VaryingsPassToPS vpass;
			};

			struct PackedVaryingsToPS
			{
				float3 vmeshInterp00 : TEXCOORD0;
				float4 vmeshPositionCS : SV_Position;
				float3 vpassInterpolators0 : TEXCOORD1;
				float3 vpassInterpolators1 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			sampler2D _MotionPowerWeightMask;
			float4x4 unity_CameraProjection;
			float4x4 unity_CameraInvProjection;
			float4x4 unity_WorldToCamera;
			float4x4 unity_CameraToWorld;
			sampler2D _Albedo_MaskA;
			CBUFFER_START( UnityPerMaterial )
			float _MotionSpeed;
			float _MotionRange;
			float _WorldSpaceOffset;
			float _SwitchRow;
			float _SwitchColumn;
			float _DarknessOnSundown;
			float _DesaturateTranslucency;
			float _SelfIllum;
			float _Gloss;
			float _Diffusion;
			float _Translucency;
			CBUFFER_END

				
			            
			FragInputs BuildFragInputs(VaryingsMeshToPS input)
			{
				FragInputs output;
				ZERO_INITIALIZE(FragInputs, output);
				output.tangentToWorld = k_identity3x3;
				output.positionSS = input.positionCS;
				output.positionRWS = input.positionRWS;
				return output;
			}
                
			void BuildSurfaceData(FragInputs fragInputs, AlphaSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
			{
				ZERO_INITIALIZE(SurfaceData, surfaceData);
				surfaceData.ambientOcclusion =      1.0f;
				surfaceData.subsurfaceMask =        1.0f;
				surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
				#endif
				#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
				#endif
				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
				#endif
				#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
				#endif
				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
				#endif
				#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
				#endif
        
				float3 normalTS =                   float3(0.0f, 0.0f, 1.0f);
				float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
				surfaceData.tangentWS = normalize(fragInputs.tangentToWorld[0].xyz);    // The tangent is not normalize in tangentToWorld for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
				surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
				surfaceData.anisotropy = 0;
				surfaceData.coatMask = 0.0f;
				surfaceData.iridescenceThickness = 0.0;
				surfaceData.iridescenceMask = 1.0;
				surfaceData.ior = 1.0;
				surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
				surfaceData.atDistance = 1000000.0;
				surfaceData.transmittanceMask = 0.0;
				surfaceData.specularOcclusion = 1.0;
				#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData);
				#elif defined(_MASKMAP)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
				#endif
				#if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
				#endif
			}
        
			void GetSurfaceAndBuiltinData(AlphaSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
			{
				#if _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif
				BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
				builtinData.distortion = float2(0.0, 0.0);
				builtinData.distortionBlur = 0.0;
				builtinData.depthOffset = 0.0;
				PostInitBuiltinData(V, posInput, surfaceData, builtinData);
			}
        

			VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsToPS input)
			{
				VaryingsMeshToPS output;
				output.positionCS = input.vmeshPositionCS;
				output.positionRWS = input.vmeshInterp00.xyz;
				return output;
			}

			VaryingsPassToPS UnpackVaryingsPassToPS(PackedVaryingsToPS input)
			{
				VaryingsPassToPS output;
				output.positionCS = float4(input.vpassInterpolators0.xy, 0.0, input.vpassInterpolators0.z);
				output.previousPositionCS = float4(input.vpassInterpolators1.xy, 0.0, input.vpassInterpolators1.z);

				return output;
			}

			PackedVaryingsToPS PackVaryingsToPS(VaryingsToPS varyingsType)
			{
				PackedVaryingsToPS outputPackedVaryingsToPS;
					
				outputPackedVaryingsToPS.vmeshPositionCS = varyingsType.vmesh.positionCS;
				outputPackedVaryingsToPS.vmeshInterp00.xyz = varyingsType.vmesh.positionRWS;
				outputPackedVaryingsToPS.vpassInterpolators0 = float3(varyingsType.vpass.positionCS.xyw);
				outputPackedVaryingsToPS.vpassInterpolators1 = float3(varyingsType.vpass.previousPositionCS.xyw);
				return outputPackedVaryingsToPS;
			}
#if UNITY_VERSION < 201930
			float3 TransformPreviousObjectToWorldNormal(float3 normalOS)
			{
				#ifdef UNITY_ASSUME_UNIFORM_SCALING
				return normalize(mul((float3x3)unity_MatrixPreviousM, normalOS));
				#else
				return normalize(mul(normalOS, (float3x3)unity_MatrixPreviousMI));
				#endif
			}

			float3 TransformPreviousObjectToWorld(float3 positionOS)
			{
				float4x4 previousModelMatrix = ApplyCameraTranslationToMatrix(unity_MatrixPreviousM);
				return mul(previousModelMatrix, float4(positionOS, 1.0)).xyz;
			}
#endif
			void VelocityPositionZBias(VaryingsToPS input)
			{
				#if defined(UNITY_REVERSED_Z)
				input.vmesh.positionCS.z -= unity_MotionVectorsParams.z * input.vmesh.positionCS.w;
				#else
				input.vmesh.positionCS.z += unity_MotionVectorsParams.z * input.vmesh.positionCS.w;
				#endif
			}

			PackedVaryingsToPS Vert(AttributesMesh inputMesh,
									AttributesPass inputPass
									
									)
			{
				PackedVaryingsToPS outputPackedVaryingsToPS;
				VaryingsToPS varyingsType;
				VaryingsMeshToPS outputVaryingsMeshToPS;

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsToPS );

				float mulTime28 = _TimeParameters.y * _MotionSpeed;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 temp_cast_0 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
				float2 uv022 = inputMesh.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode47 = tex2Dlod( _MotionPowerWeightMask, float4( appendResult35, 0, 0.0) );
				
				outputPackedVaryingsToPS.ase_texcoord3.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsToPS.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = inputMesh.positionOS.xyz;
				#else
				float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = ( inputMesh.normalOS * ( ( sin( ( mulTime28 + ( ase_worldPos.x + ase_worldPos.z ) ) ) * _MotionRange ) * tex2DNode47.r * tex2DNode47.g * tex2DNode47.b ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS =  inputMesh.normalOS ;

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
				outputVaryingsMeshToPS.positionRWS = positionRWS;
				outputVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
					

				varyingsType.vmesh = outputVaryingsMeshToPS;

				VelocityPositionZBias(varyingsType);
				varyingsType.vpass.positionCS = mul(_NonJitteredViewProjMatrix, float4(varyingsType.vmesh.positionRWS, 1.0));
				bool forceNoMotion = unity_MotionVectorsParams.y == 0.0;
				if (forceNoMotion)
				{
					varyingsType.vpass.previousPositionCS = float4(0.0, 0.0, 0.0, 1.0);
				}
				else
				{
					bool hasDeformation = unity_MotionVectorsParams.x > 0.0; // Skin or morph target

					float3 previousPositionRWS = TransformPreviousObjectToWorld(hasDeformation ? inputPass.previousPositionOS : inputMesh.positionOS);

					float3 normalWS = float3(0.0, 0.0, 0.0);

					varyingsType.vpass.previousPositionCS = mul(_PrevViewProjMatrix, float4(previousPositionRWS, 1.0));
				}

				outputPackedVaryingsToPS.vmeshPositionCS = varyingsType.vmesh.positionCS;
				outputPackedVaryingsToPS.vmeshInterp00.xyz = varyingsType.vmesh.positionRWS;
					
				outputPackedVaryingsToPS.vpassInterpolators0 = float3(varyingsType.vpass.positionCS.xyw);
				outputPackedVaryingsToPS.vpassInterpolators1 = float3(varyingsType.vpass.previousPositionCS.xyw);
					
				return outputPackedVaryingsToPS;
			}

			void Frag(	PackedVaryingsToPS packedInput
						, out float4 outMotionVector : SV_Target0
						#ifdef WRITE_NORMAL_BUFFER
						, out float4 outNormalBuffer : SV_Target1
						#ifdef WRITE_MSAA_DEPTH
						, out float1 depthColor : SV_Target2
						#endif
						#elif defined(WRITE_MSAA_DEPTH) 
						, out float4 outNormalBuffer : SV_Target1
						, out float1 depthColor : SV_Target2
						#endif
						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						
					)
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );
				VaryingsMeshToPS unpacked= UnpackVaryingsMeshToPS(packedInput);
				FragInputs input = BuildFragInputs(unpacked);
					

				PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

				float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);

				SurfaceData surfaceData;
				BuiltinData builtinData;
					
				AlphaSurfaceDescription surfaceDescription = (AlphaSurfaceDescription)0;
                float2 temp_cast_0 = (0.0).xx;
                float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
                float ifLocalVar13 = 0;
                UNITY_BRANCH 
                if( frac( objToWorld8.x ) <= 0.5 )
                ifLocalVar13 = 0.5;
                else
                ifLocalVar13 = 1.0;
                float ifLocalVar14 = 0;
                UNITY_BRANCH 
                if( frac( objToWorld8.z ) <= 0.5 )
                ifLocalVar14 = 0.5;
                else
                ifLocalVar14 = 1.0;
                float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
                float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
                float2 uv022 = packedInput.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
                float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
                float4 tex2DNode37 = tex2D( _Albedo_MaskA, appendResult35 );
                
				surfaceDescription.Alpha = tex2DNode37.a;
				surfaceDescription.AlphaClipThreshold = 0.5;
	
				GetSurfaceAndBuiltinData(surfaceDescription,input, V, posInput, surfaceData, builtinData);

				VaryingsPassToPS inputPass = UnpackVaryingsPassToPS(packedInput);
				#ifdef _DEPTHOFFSET_ON
				inputPass.positionCS.w += builtinData.depthOffset;
				inputPass.previousPositionCS.w += builtinData.depthOffset;
				#endif

				float2 motionVector = CalculateMotionVector (inputPass.positionCS, inputPass.previousPositionCS);
				EncodeMotionVector (motionVector * 0.5, outMotionVector);

				bool forceNoMotion = unity_MotionVectorsParams.y == 0.0;
				if (forceNoMotion)
					outMotionVector = float4(2.0, 0.0, 0.0, 0.0);

				#ifdef WRITE_NORMAL_BUFFER
				EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);

				#ifdef WRITE_MSAA_DEPTH
				depthColor = packedInput.vmeshPositionCS.z;
				#endif
				#elif defined(WRITE_MSAA_DEPTH) 
				outNormalBuffer = float4(0.0, 0.0, 0.0, 1.0);
				depthColor = packedInput.vmeshPositionCS.z;
				#endif

				#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
				#endif
			}

            ENDHLSL
        }

		
        Pass
        {
            
            
			Name "Forward"
			Tags { "LightMode"="Forward" }
			Stencil
			{
				Ref 2
				WriteMask 51
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}


            HLSLPROGRAM
            #define _MATERIAL_FEATURE_TRANSMISSION 1
            #define _MATERIAL_FEATURE_SPECULAR_COLOR 1
            #define _NORMALMAP 1
            #define _ALPHATEST_ON 1
            #define ASE_SRP_VERSION 70108

            //#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag
        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            #define SHADERPASS SHADERPASS_FORWARD
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
            #pragma multi_compile USE_FPTL_LIGHTLIST USE_CLUSTERED_LIGHTLIST
			#pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH
				
			#define SHADERPASS_FORWARD_BYPASS_ALPHA_TEST

            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
        
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
        
			#define HAS_LIGHTLOOP
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
        
        
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
			
				
			struct AttributesMesh 
			{
				float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float4 uv1 : TEXCOORD1;
				float4 uv2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
        
			struct PackedVaryingsMeshToPS 
			{
				float4 positionCS : SV_Position;
				float3 interp00 : TEXCOORD0;
				float3 interp01 : TEXCOORD1;
				float4 interp02 : TEXCOORD2;
				float4 interp03 : TEXCOORD3;
				float4 interp04 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MotionPowerWeightMask;
			float4x4 unity_CameraProjection;
			float4x4 unity_CameraInvProjection;
			float4x4 unity_WorldToCamera;
			float4x4 unity_CameraToWorld;
			sampler2D _Albedo_MaskA;
			sampler2D _NormalMap;
			sampler2D _TranslucencyMap;
			CBUFFER_START( UnityPerMaterial )
			float _MotionSpeed;
			float _MotionRange;
			float _WorldSpaceOffset;
			float _SwitchRow;
			float _SwitchColumn;
			float _DarknessOnSundown;
			float _DesaturateTranslucency;
			float _SelfIllum;
			float _Gloss;
			float _Diffusion;
			float _Translucency;
			CBUFFER_END

				
			                
        
			void BuildSurfaceData ( FragInputs fragInputs, GlobalSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData )
			{
				ZERO_INITIALIZE ( SurfaceData, surfaceData );

				float3 normalTS = float3( 0.0f, 0.0f, 1.0f );
				normalTS = surfaceDescription.Normal;
				float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS ( fragInputs, normalTS, surfaceData.normalWS ,doubleSidedConstants);

				surfaceData.ambientOcclusion = 1.0f;

				surfaceData.baseColor = surfaceDescription.Albedo;
				surfaceData.perceptualSmoothness = surfaceDescription.Smoothness;
				surfaceData.ambientOcclusion = surfaceDescription.Occlusion;

				surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;

				#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
				surfaceData.specularColor = surfaceDescription.Specular;
				#else
				surfaceData.metallic = surfaceDescription.Metallic;
				#endif

				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceData.diffusionProfileHash = asuint(surfaceDescription.DiffusionProfile);
				#endif

				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
				surfaceData.subsurfaceMask = surfaceDescription.SubsurfaceMask;
				#else
				surfaceData.subsurfaceMask = 1.0f;
				#endif

				#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
				surfaceData.thickness = surfaceDescription.Thickness;
				#endif

				surfaceData.tangentWS = normalize ( fragInputs.tangentToWorld[ 0 ].xyz );
				surfaceData.tangentWS = Orthonormalize ( surfaceData.tangentWS, surfaceData.normalWS );

				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
				surfaceData.anisotropy = surfaceDescription.Anisotropy;

				#else
				surfaceData.anisotropy = 0;
				#endif

				#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
				surfaceData.coatMask = surfaceDescription.CoatMask;
				#else
				surfaceData.coatMask = 0.0f;
				#endif

				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
				surfaceData.iridescenceThickness = surfaceDescription.IridescenceThickness;
				surfaceData.iridescenceMask = surfaceDescription.IridescenceMask;
				#else
				surfaceData.iridescenceThickness = 0.0;
				surfaceData.iridescenceMask = 1.0;
				#endif

				//ASE CUSTOM TAG
				#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceData.ior = surfaceDescription.IndexOfRefraction;
				surfaceData.transmittanceColor = surfaceDescription.TransmittanceColor;
				surfaceData.atDistance = surfaceDescription.TransmittanceAbsorptionDistance;
				surfaceData.transmittanceMask = surfaceDescription.TransmittanceMask;
				#else
				surfaceData.ior = 1.0;
				surfaceData.transmittanceColor = float3( 1.0, 1.0, 1.0 );
				surfaceData.atDistance = 1000000.0;
				surfaceData.transmittanceMask = 0.0;
				#endif

				surfaceData.specularOcclusion = 1.0;

				#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO ( V, bentNormalWS, surfaceData );
				#elif defined(_MASKMAP)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion ( NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness ( surfaceData.perceptualSmoothness ) );
				#endif
				#if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
				#endif
			}
        
			void GetSurfaceAndBuiltinData( GlobalSurfaceDescription surfaceDescription , FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
			{
				#if _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif
		
				BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.tangentToWorld[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
				builtinData.emissiveColor =             surfaceDescription.Emission;
				builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
				builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
        
				builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
        
				PostInitBuiltinData(V, posInput, surfaceData, builtinData);
			}
        
			
			PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

				UNITY_SETUP_INSTANCE_ID(inputMesh);
				UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

				float mulTime28 = _TimeParameters.y * _MotionSpeed;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				float2 temp_cast_0 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_0 ));
				float2 uv022 = inputMesh.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode47 = tex2Dlod( _MotionPowerWeightMask, float4( appendResult35, 0, 0.0) );
				
				outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				float3 defaultVertexValue = inputMesh.positionOS.xyz;
				#else
				float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = ( inputMesh.normalOS * ( ( sin( ( mulTime28 + ( ase_worldPos.x + ase_worldPos.z ) ) ) * _MotionRange ) * tex2DNode47.r * tex2DNode47.g * tex2DNode47.b ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif
					
				inputMesh.normalOS =  inputMesh.normalOS ;

				float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
				float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
				float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

				outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
				outputPackedVaryingsMeshToPS.interp00.xyz = positionRWS;
				outputPackedVaryingsMeshToPS.interp01.xyz = normalWS;
				outputPackedVaryingsMeshToPS.interp02.xyzw = tangentWS;
				outputPackedVaryingsMeshToPS.interp03.xyzw = inputMesh.uv1;
				outputPackedVaryingsMeshToPS.interp04.xyzw = inputMesh.uv2;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( outputPackedVaryingsMeshToPS );
				return outputPackedVaryingsMeshToPS;
			}

			void Frag(	PackedVaryingsMeshToPS packedInput,
						#ifdef OUTPUT_SPLIT_LIGHTING
						out float4 outColor : SV_Target0, 
						out float4 outDiffuseLighting : SV_Target1,
						OUTPUT_SSSBUFFER (outSSSBuffer)
						#else
						out float4 outColor : SV_Target0
						#ifdef _WRITE_TRANSPARENT_MOTION_VECTOR
						, out float4 outMotionVec : SV_Target1
						#endif 
						#endif 
						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						 
						)
			{
				UNITY_SETUP_INSTANCE_ID( packedInput );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( packedInput );
				FragInputs input;
				ZERO_INITIALIZE(FragInputs, input);
        
				input.tangentToWorld = k_identity3x3;
				input.positionSS = packedInput.positionCS;
				float3 positionRWS = packedInput.interp00.xyz;
				float3 normalWS = packedInput.interp01.xyz;
				float4 tangentWS = packedInput.interp02.xyzw;
						
				input.positionRWS = positionRWS;
				input.tangentToWorld = BuildTangentToWorld(tangentWS, normalWS);
				input.texCoord1 = packedInput.interp03.xyzw;
				input.texCoord2 = packedInput.interp04.xyzw;

				// input.positionSS is SV_Position
				PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, uint2(input.positionSS.xy) / GetTileSize() );

				float3 normalizedWorldViewDir = GetWorldSpaceNormalizeViewDir ( input.positionRWS );

				SurfaceData surfaceData;
				BuiltinData builtinData;
				GlobalSurfaceDescription surfaceDescription = ( GlobalSurfaceDescription ) 0;
				float dotResult39 = dot( float3(0,1,0) , SafeNormalize(-_DirectionalLightDatas[0].forward) );
				float clampResult43 = clamp( dotResult39 , 0.0 , 1.0 );
				float3 temp_cast_0 = (clampResult43).xxx;
				float temp_output_2_0_g3 = _DarknessOnSundown;
				float temp_output_3_0_g3 = ( 1.0 - temp_output_2_0_g3 );
				float3 appendResult7_g3 = (float3(temp_output_3_0_g3 , temp_output_3_0_g3 , temp_output_3_0_g3));
				float3 temp_output_50_0 = ( ( temp_cast_0 * temp_output_2_0_g3 ) + appendResult7_g3 );
				float2 temp_cast_2 = (0.0).xx;
				float3 objToWorld8 = GetAbsolutePositionWS(mul( GetObjectToWorldMatrix(), float4( float3( 0,0,0 ), 1 ) ).xyz);
				float ifLocalVar13 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.x ) <= 0.5 )
				ifLocalVar13 = 0.5;
				else
				ifLocalVar13 = 1.0;
				float ifLocalVar14 = 0;
				UNITY_BRANCH 
				if( frac( objToWorld8.z ) <= 0.5 )
				ifLocalVar14 = 0.5;
				else
				ifLocalVar14 = 1.0;
				float2 appendResult15 = (float2(ifLocalVar13 , ifLocalVar14));
				float2 break23 = (( _WorldSpaceOffset )?( appendResult15 ):( temp_cast_2 ));
				float2 uv022 = packedInput.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult35 = (float2(( break23.x + uv022.x + (( _SwitchRow )?( 0.5 ):( 0.0 )) ) , ( break23.y + uv022.y + (( _SwitchColumn )?( 0.5 ):( 0.0 )) )));
				float4 tex2DNode37 = tex2D( _Albedo_MaskA, appendResult35 );
				
				float3 desaturateInitialColor97 = tex2DNode37.rgb;
				float desaturateDot97 = dot( desaturateInitialColor97, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar97 = lerp( desaturateInitialColor97, desaturateDot97.xxx, _DesaturateTranslucency );
				
				float3 desaturateInitialColor54 = tex2D( _TranslucencyMap, appendResult35 ).rgb;
				float desaturateDot54 = dot( desaturateInitialColor54, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar54 = lerp( desaturateInitialColor54, desaturateDot54.xxx, _DesaturateTranslucency );
				
				surfaceDescription.Albedo = ( float4( temp_output_50_0 , 0.0 ) * tex2DNode37 ).rgb;
				surfaceDescription.Normal = UnpackNormalmapRGorAG( tex2D( _NormalMap, appendResult35 ), 1.0f );
				surfaceDescription.Emission = ( desaturateVar97 * _SelfIllum );
				surfaceDescription.Specular = 0;
				surfaceDescription.Metallic = 0;
				surfaceDescription.Smoothness = _Gloss;
				surfaceDescription.Occlusion = 1;
				surfaceDescription.Alpha = tex2DNode37.a;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceDescription.CoatMask = 0;
				#endif

				#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceDescription.DiffusionProfile = _Diffusion;
				#endif

				#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceDescription.SubsurfaceMask = 1;
				#endif

				#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceDescription.Thickness = ( desaturateVar54 * _Translucency ).x;
				#endif

				#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceDescription.Anisotropy = 0;
				#endif

				#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceDescription.IridescenceThickness = 0;
				surfaceDescription.IridescenceMask = 1;
				#endif

				#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceDescription.IndexOfRefraction = 1;
				surfaceDescription.TransmittanceColor = float3( 1, 1, 1 );
				surfaceDescription.TransmittanceAbsorptionDistance = 1000000;
				surfaceDescription.TransmittanceMask = 0;
				#endif
				GetSurfaceAndBuiltinData(surfaceDescription, input, normalizedWorldViewDir, posInput, surfaceData, builtinData);

				BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);

				PreLightData preLightData = GetPreLightData(normalizedWorldViewDir, posInput, bsdfData);

				outColor = float4(0.0, 0.0, 0.0, 0.0);

				{
					#ifdef _SURFACE_TYPE_TRANSPARENT
					uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_TRANSPARENT;
					#else
					uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_OPAQUE;
					#endif
					float3 diffuseLighting;
					float3 specularLighting;

					LightLoop(normalizedWorldViewDir, posInput, preLightData, bsdfData, builtinData, featureFlags, diffuseLighting, specularLighting);
						
					diffuseLighting *= GetCurrentExposureMultiplier();
					specularLighting *= GetCurrentExposureMultiplier();

					#ifdef OUTPUT_SPLIT_LIGHTING
					if (_EnableSubsurfaceScattering != 0 && ShouldOutputSplitLighting(bsdfData))
					{
						outColor = float4(specularLighting, 1.0);
						outDiffuseLighting = float4(TagLightingForSSS(diffuseLighting), 1.0);
					}
					else
					{
						outColor = float4(diffuseLighting + specularLighting, 1.0);
						outDiffuseLighting = 0;
					}
					ENCODE_INTO_SSSBUFFER(surfaceData, posInput.positionSS, outSSSBuffer);
					#else
					outColor = ApplyBlendMode(diffuseLighting, specularLighting, builtinData.opacity);
					outColor = EvaluateAtmosphericScattering(posInput, normalizedWorldViewDir, outColor);
					#endif
					#ifdef _WRITE_TRANSPARENT_MOTION_VECTOR
					//VaryingsPassToPS inputPass = UnpackVaryingsPassToPS (packedInput.vpass);
					//bool forceNoMotion = any (unity_MotionVectorsParams.yw == 0.0);
					//if (forceNoMotion)
					//{
					//	outMotionVec = float4(2.0, 0.0, 0.0, 0.0);
					//}
					//else
					//{
					//	float2 motionVec = CalculateMotionVector (inputPass.positionCS, inputPass.previousPositionCS);
					//	EncodeMotionVector (motionVec * 0.5, outMotionVec);
					//	outMotionVec.zw = 1.0;
					//}
					#endif
				}

				#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
				#endif
			}

            ENDHLSL
        }
		
    }
    Fallback "Hidden/InternalErrorShader"
	CustomEditor "ASEMaterialInspector"
	
}
/*ASEBEGIN
Version=17700
0;0;1920;1029;3088.776;1745.271;2.655875;True;True
Node;AmplifyShaderEditor.CommentaryNode;7;-4755.078,-778.5502;Inherit;False;2138.514;828.9008;WorldSpace Texture Quad switching;19;35;29;27;24;23;22;21;19;18;17;16;15;14;13;12;11;10;9;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;8;-4705.078,-676.9653;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FractNode;9;-4344.864,-728.5502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-4292.864,-667.4501;Float;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-4286.364,-597.2501;Float;False;Constant;_Float2;Float 2;0;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;12;-4421.564,-558.2501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;13;-4067.964,-718.1501;Inherit;False;True;5;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;14;-4061.464,-428.2501;Inherit;False;True;5;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;20;-2550.018,200.6973;Inherit;False;1457.572;714.0665;MotionControl;12;57;55;52;47;46;41;40;34;31;28;26;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-3814.464,-573.8501;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-3815.764,-651.8494;Float;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-3841.764,-225.4495;Float;False;Constant;_Float4;Float 4;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-3850.864,-92.84937;Float;False;Constant;_Float5;Float 5;2;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2492.366,325.3357;Float;False;Property;_MotionSpeed;MotionSpeed;11;0;Create;True;0;0;False;0;1;2.99;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;18;-3602.564,-602.4495;Float;False;Property;_WorldSpaceOffset;WorldSpaceOffset?;3;0;Create;True;0;0;False;0;1;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;25;-2500.018,489.1086;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-2160.228,513.5981;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;30;-2061.978,-1319.837;Inherit;False;1509.034;413.6017;SundownDarkness;6;50;43;42;39;36;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;28;-2161.76,342.1721;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;24;-3619.463,-87.64938;Float;False;Property;_SwitchColumn;SwitchColumn;4;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-3336.064,-498.4493;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;21;-3609.064,-199.4494;Float;False;Property;_SwitchRow;SwitchRow;5;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;23;-3349.064,-599.8494;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-1892.374,401.8654;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;36;-1941.429,-1261.924;Float;False;Constant;_Vector0;Vector 0;15;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;33;-2011.978,-1085.235;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-3009.764,-536.1494;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-3016.265,-390.5492;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;35;-2783.564,-468.5492;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;39;-1650.932,-1144.422;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;41;-1690.335,403.3958;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1802.889,569.9817;Float;False;Property;_MotionRange;MotionRange;12;0;Create;True;0;0;False;0;0.5;2.25;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;49;-2541.868,-284.5916;Inherit;True;Property;_TranslucencyMap;TranslucencyMap;8;0;Create;True;0;0;False;0;-1;None;c74914b5e72b0c0469ab52085cb6c6b0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1509.727,391.1509;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1203.603,-988.054;Float;False;Property;_DarknessOnSundown;DarknessOnSundown;2;0;Create;True;0;0;False;0;0.75;0.758;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;47;-1772.056,684.7637;Inherit;True;Property;_MotionPowerWeightMask;MotionPowerWeightMask;10;0;Create;True;0;0;False;0;-1;None;53572511f4383b843a0bbbcbfe0466bf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;43;-1156.878,-1142.738;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2237.331,-179.4655;Float;False;Property;_DesaturateTranslucency;DesaturateTranslucency;0;0;Create;True;0;0;False;0;0.4;0.51;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-2608.254,-703.3415;Inherit;True;Property;_Albedo_MaskA;Albedo_Mask(A);7;0;Create;True;0;0;False;0;-1;None;3b76bdb3d2d04ba4093d25ea616ca667;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;50;-763.9441,-1143.414;Inherit;False;Lerp White To;-1;;3;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-1826.44,-165.4134;Inherit;False;Property;_Translucency;Translucency;14;0;Create;True;0;0;False;0;2;0.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1300.397,534.8417;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;55;-1720.846,250.6973;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;54;-1906.57,-271.1471;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DesaturateOpNode;97;-2061.675,-629.9933;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2598.916,-463.5498;Float;False;Property;_SelfIllum;SelfIllum;1;0;Create;True;0;0;False;0;0;0.891;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;97.42656,-332.0605;Inherit;False;Constant;_Float0;Float 0;14;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;236.9893,-469.5875;Float;False;Property;_Gloss;Gloss;6;0;Create;True;0;0;False;0;0.2;0.528;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-2574.59,-35.06436;Inherit;True;Property;_NormalMap;NormalMap;9;0;Create;True;0;0;False;0;-1;None;880b830756accc440b420f7086ebfa39;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-1424.56,-218.0406;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-45.96642,-675.2422;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1261.446,347.4567;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-190.2799,-566.5179;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DiffusionProfileNode;94;417.9329,-356.9017;Float;False;Property;_Diffusion;Diffusion;13;0;Create;True;0;0;False;0;78322c7f82657514ebe48203160e3f39;78322c7f82657514ebe48203160e3f39;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1760.992,-487.3851;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;bb308bce79762c34e823049efce65141;True;DepthOnly;0;4;DepthOnly;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;0;False;-1;255;False;-1;48;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Translucent;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;bb308bce79762c34e823049efce65141;True;ShadowCaster;0;2;ShadowCaster;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Translucent;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;779.0515,-589.301;Float;False;True;-1;2;ASEMaterialInspector;0;4;WorldSpaceTrees/HDRP_TreeLeafSwitcher;bb308bce79762c34e823049efce65141;True;GBuffer;0;0;GBuffer;22;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=TreeTransparentCutout=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;2;False;-1;255;False;-1;51;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=GBuffer;False;0;Hidden/InternalErrorShader;0;0;Translucent;1;Vertex Position,InvertActionOnDeselection;1;0;7;True;True;True;True;True;True;True;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;bb308bce79762c34e823049efce65141;True;Forward;0;6;Forward;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;2;False;-1;255;False;-1;51;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=Forward;False;0;Hidden/InternalErrorShader;0;0;Translucent;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;bb308bce79762c34e823049efce65141;True;META;0;1;META;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Translucent;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;bb308bce79762c34e823049efce65141;True;Motion Vectors;0;5;Motion Vectors;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;False;True;True;128;False;-1;255;False;-1;176;False;-1;7;False;-1;3;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;True;1;LightMode=MotionVectors;False;0;Hidden/InternalErrorShader;0;0;Translucent;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;ASEMaterialInspector;0;1;New Amplify Shader;bb308bce79762c34e823049efce65141;True;SceneSelectionPass;0;3;SceneSelectionPass;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;False;False;True;1;False;-1;True;3;False;-1;False;True;3;RenderPipeline=HDRenderPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;0;Hidden/InternalErrorShader;0;0;Translucent;0;0
WireConnection;9;0;8;1
WireConnection;12;0;8;3
WireConnection;13;0;9;0
WireConnection;13;1;10;0
WireConnection;13;2;11;0
WireConnection;13;3;10;0
WireConnection;13;4;10;0
WireConnection;14;0;12;0
WireConnection;14;1;10;0
WireConnection;14;2;11;0
WireConnection;14;3;10;0
WireConnection;14;4;10;0
WireConnection;15;0;13;0
WireConnection;15;1;14;0
WireConnection;18;0;16;0
WireConnection;18;1;15;0
WireConnection;31;0;25;1
WireConnection;31;1;25;3
WireConnection;28;0;26;0
WireConnection;24;0;19;0
WireConnection;24;1;17;0
WireConnection;21;0;19;0
WireConnection;21;1;17;0
WireConnection;23;0;18;0
WireConnection;34;0;28;0
WireConnection;34;1;31;0
WireConnection;27;0;23;0
WireConnection;27;1;22;1
WireConnection;27;2;21;0
WireConnection;29;0;23;1
WireConnection;29;1;22;2
WireConnection;29;2;24;0
WireConnection;35;0;27;0
WireConnection;35;1;29;0
WireConnection;39;0;36;0
WireConnection;39;1;33;0
WireConnection;41;0;34;0
WireConnection;49;1;35;0
WireConnection;46;0;41;0
WireConnection;46;1;40;0
WireConnection;47;1;35;0
WireConnection;43;0;39;0
WireConnection;37;1;35;0
WireConnection;50;1;43;0
WireConnection;50;2;42;0
WireConnection;52;0;46;0
WireConnection;52;1;47;1
WireConnection;52;2;47;2
WireConnection;52;3;47;3
WireConnection;54;0;49;0
WireConnection;54;1;48;0
WireConnection;97;0;37;0
WireConnection;97;1;48;0
WireConnection;59;1;35;0
WireConnection;96;0;54;0
WireConnection;96;1;95;0
WireConnection;60;0;50;0
WireConnection;60;1;37;0
WireConnection;57;0;55;0
WireConnection;57;1;52;0
WireConnection;91;0;50;0
WireConnection;89;0;97;0
WireConnection;89;1;45;0
WireConnection;0;0;60;0
WireConnection;0;1;59;0
WireConnection;0;2;89;0
WireConnection;0;5;58;0
WireConnection;0;7;37;4
WireConnection;0;8;63;0
WireConnection;0;12;94;0
WireConnection;0;14;96;0
WireConnection;0;9;57;0
ASEEND*/
//CHKSM=C962D540D9B94AE3B51F012627286094BBF5176F