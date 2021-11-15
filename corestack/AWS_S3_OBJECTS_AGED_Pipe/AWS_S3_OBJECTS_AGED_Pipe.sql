CREATE OR ALTER PROCEDURE [CostPolicy].[AWS_S3_Pipeline]
(
    -- Add the parameters for the stored procedure here
    @ServiceAccountID BIGINT,
	@DaysElapsed INT,
	@IsAssessment BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON

	SELECT AV1.ResourceID as ResourceId,
    SA.ID AS ServiceAccountId,
    AV1.Value as [Object], 
    AV2.Value as ResourceName, 
    AV3.Value as Size, 
    AV4.Value as [Last Modified], 
    I.Location as Region,
    I.ResourceType
	FROM report.ServiceResourceAttributeValue AV1
		INNER JOIN report.ServiceResourceAttributeValue AV2
			ON AV1.ResourceID = AV2.ResourceID
		INNER JOIN report.ServiceResourceAttributeValue AV3
			ON AV2.ResourceID = AV3.ResourceID
		INNER JOIN report.ServiceResourceAttributeValue AV4
			ON AV3.ResourceID = AV4.ResourceID
		INNER JOIN report.ServiceResourceInventory I
			ON I.ResourceID = AV1.ResourceID
		INNER JOIN report.ServiceAccount SA
			ON I.ServiceAccountID = SA.ServiceAccountID
	WHERE AV1.Attribute = 'object_Name' 
		AND AV2.Attribute = 'BucketName'
		AND AV3.Attribute = 'Size(KB)'
		AND AV4.Attribute = 'LastModified'
		AND DATEDIFF(DAY, AV4.Value, GETDATE()) >= @DaysElapsed
		AND SA.ServiceAccountID = @ServiceAccountID

	IF @IsAssessment = 1
	BEGIN
	SELECT *
	FROM
	(
		SELECT COUNT(*) AS ViolatedResourceCount
		FROM report.ServiceResourceAttributeValue AV1
			INNER JOIN report.ServiceResourceAttributeValue AV2
				ON AV1.ResourceID = AV2.ResourceID
			INNER JOIN report.ServiceResourceAttributeValue AV3
				ON AV2.ResourceID = AV3.ResourceID
			INNER JOIN report.ServiceResourceAttributeValue AV4
				ON AV3.ResourceID = AV4.ResourceID
			INNER JOIN report.ServiceResourceInventory I
				ON I.ResourceID = AV1.ResourceID
			INNER JOIN report.ServiceAccount SA
				ON I.ServiceAccountID = SA.ServiceAccountID
		WHERE AV1.Attribute = 'object_Name' 
			AND AV2.Attribute = 'BucketName'
			AND AV3.Attribute = 'Size(KB)'
			AND AV4.Attribute = 'LastModified'
			AND DATEDIFF(DAY, AV4.Value, GETDATE()) >= @DaysElapsed
			AND SA.ServiceAccountID = @ServiceAccountID
	) AS ViolatedResourceCount,
		(
		SELECT COUNT(*) AS TotalResourceCount
		FROM report.ServiceResourceAttributeValue AV1
			INNER JOIN report.ServiceResourceAttributeValue AV2
				ON AV1.ResourceID = AV2.ResourceID
			INNER JOIN report.ServiceResourceAttributeValue AV3
				ON AV2.ResourceID = AV3.ResourceID
			INNER JOIN report.ServiceResourceAttributeValue AV4
				ON AV3.ResourceID = AV4.ResourceID
			INNER JOIN report.ServiceResourceInventory I
				ON I.ResourceID = AV1.ResourceID
			INNER JOIN report.ServiceAccount SA
				ON I.ServiceAccountID = SA.ServiceAccountID
		WHERE AV1.Attribute = 'object_Name' 
			AND AV2.Attribute = 'BucketName'
			AND AV3.Attribute = 'Size(KB)'
			AND AV4.Attribute = 'LastModified'
			AND SA.ServiceAccountID = @ServiceAccountID
	) AS TotalResourceCount
	END
END
