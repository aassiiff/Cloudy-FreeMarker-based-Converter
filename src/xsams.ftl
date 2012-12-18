<#ftl ns_prefixes={"D":"http://vamdc.org/xml/xsams/0.3", 
	"xsams":"http://vamdc.org/xml/xsams/0.3"}> 

 
 <#-- 
 	Giving errors due to default namespace ... should fix it.
 	"D":"http://vamdc.org/xml/xsams/0.3",
 	
 	${atomState.AtomicQuantumNumbers?size}
 	
	atomState.AtomicQuantumNumbers?size: ${atomState.AtomicQuantumNumbers?size}
 -->
<#assign elementName = "">
<#assign ionCharge = 1>
<#assign statisticalWeight = 1>
<#assign totalAngularMomentumUpper = 0>
<#assign totalAngularMomentumLower = 0>
<#assign gu = 0>
<#assign gl = 0>
<#assign waveLength = 0>
<#assign energy = 0>
<#assign transProbabilityA = 0>
<#assign oscillatorStrength = 0>
<#assign log10scillatorStrength = 0>
<#assign weightedOscillatorStrength = 0>
<#assign gf = 0>
<#assign processRT = "">
<#assign redis = 1>
<#assign biblioRef = "">

<#macro biblioMacro sourceref>
	<#list doc.XSAMSData.Sources.Source as source>
		<#if source.@sourceID = sourceref>
			<#assign biblioRef = "#>>">
			<#list source.Authors.Author as author>
				<#assign biblioRef = biblioRef + "  ${author.Name}">
			</#list>	
			<#list source.SourceName as sourceName>
				<#assign biblioRef = biblioRef + "  ${sourceName}">	
			</#list>
		</#if>
	</#list>
</#macro>
<#macro stateRef upperState lowerState>
	<#list doc.XSAMSData.Species.Atoms.Atom as atom>	
		<#list atom.Isotope as isotope>
			<#list isotope.Ion as ion>
				<#list ion.AtomicState as atomState>
					<#list atomState.AtomicNumericalData as atomicNumericalData>		
					<#if atomState.@stateID == upperState> 	
						<#list atomState.AtomicQuantumNumbers.TotalAngularMomentum as totalAngularMomentumLoop>
							<#assign totalAngularMomentumUpper ="${totalAngularMomentumLoop}">
							<#assign gu = (2 * totalAngularMomentumUpper?number) + 1>
						</#list>
						<#list atomicNumericalData.StatisticalWeight as statisticalWeightLoop>
							<#assign statisticalWeight=statisticalWeightLoop>
						</#list>					
						<#assign elementName="${atom.ChemicalElement.ElementSymbol}">
						<#assign ionCharge="${ion.IonCharge}">
						<#assign ionCharge=ionCharge?number + 1>
					<#elseif atomState.@stateID == lowerState>
						<#list atomState.AtomicQuantumNumbers.TotalAngularMomentum as totalAngularMomentumLoop>
							<#assign totalAngularMomentumLower ="${totalAngularMomentumLoop}">
							<#assign gl = (2 * totalAngularMomentumLower?number) + 1>
						</#list>
					</#if>
					</#list>
				</#list>
			</#list>
		</#list>
	</#list>
</#macro> 
 
<#list doc.XSAMSData.Processes.Radiative.RadiativeTransition as radTran>
		<#assign processRT = radTran.@process>	
		<#list radTran.SourceRef as sourceRef>
			<@biblioMacro sourceref="${sourceRef}"/>
		</#list>
		<@stateRef upperState="${radTran.UpperStateRef}" lowerState="${radTran.LowerStateRef}"/>
		<#list radTran.EnergyWavelength.Wavelength as wavelengthLoop>
			<#assign waveLength="${wavelengthLoop.Value}">
			<#assign energy = 1 / ((waveLength?number /10) * 0.0000001)>
		</#list>		
		<#list radTran.Probability.TransitionProbabilityA as transProbabilityALoop>
			<#if transProbabilityALoop.Value??>
				<#assign transProbabilityA="${transProbabilityALoop.Value}">
			</#if>
		</#list>		
		<#list radTran.Probability.OscillatorStrength as oscillatorStrengthLoop>
			<#assign oscillatorStrength="${oscillatorStrengthLoop.Value}">
		</#list>		
		<#list radTran.Probability.Log10WeightedOscillatorStrength as log10scillatorStrengthLoop>
			<#assign log10scillatorStrength="${log10scillatorStrengthLoop.Value}">
		</#list>		
		<#list radTran.Probability.WeightedOscillatorStrength as weightedOscillatorStrengthLoop>
			<#assign weightedOscillatorStrength="${weightedOscillatorStrengthLoop.Value}">
		</#list>
		<#if elementName?length &lt; 2>
			<#assign elementName="elementName ">
		</#if>	
		<#if transProbabilityA?number = 0>
			<#if log10scillatorStrength?number != 0>
				<#assign gf = log10scillatorStrength>
			<#elseif oscillatorStrength?number != 0>
				<#if processRT = "deexcitation">
					<#assign gf = oscillatorStrength * gu>
				<#elseif processRT = "excitation">
					<#assign gf = oscillatorStrength * gl>
				</#if>
			</#if>
		</#if>
		<#if biblioRef?length &gt; 5>
${biblioRef}
		</#if>
${elementName}${ionCharge?string?left_pad(2)} ${waveLength?number?string("########")?left_pad(9)} ${energy?c?number?string("########.00")?left_pad(11)} ${gl?c?left_pad(2)} ${gu?c?left_pad(2)} ${gf?string?left_pad(10)} ${transProbabilityA?string?left_pad(10)}  ${redis}	  
		<#assign upperStateEnergy = 0>
		<#assign lowerStateEnergy = 0>
</#list>

