. .\mock7.ps1

describe 'Find-SqlServerServicePack' {
    mock 'Find-SqlServerServicePackInstaller' {@{ Name = 'installername2012' }} -ParameterFilter { $Version -eq '2012' }
    mock 'Find-SqlServerServicePackInstaller' {@{ Name = 'installername2014' }} -ParameterFilter { $Version -eq '2014' }

    it 'finds the expected installer name for SQL Server 2012' {
        $result = Find-SqlServerServicePackInstaller -Version 2012
        $result.Name | should -Be 'installername2012'
    }
    it 'finds the expected installer name for SQL Server 2014' {
        $result = Find-SqlServerServicePackInstaller -Version 2014
        $result.Name | should -Be 'installername2014'
    }
}
Describe 'when the SQL installer cannot be found' {
    mock 'Find-SqlServerServicePackInstaller' {} -ParameterFilter { $true }
    it 'should return nothing' {
        Find-SqlServerServicePackInstaller -Version 2014 | should -Benullorempty
        Find-SqlServerServicePackInstaller -Version 2012 | should -Benullorempty
    }
}