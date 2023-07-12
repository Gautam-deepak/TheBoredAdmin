. .\mockscope.ps1

describe 'stuff' {
    mock Get-Content { 
        'smoochies'
    }
    context 'new context' {
        mock Get-Content { 
            'fist bump' 
        }
        it 'slaps' {
            mock Get-Content { 
                'slap' 
            }
            Read-Stuff | should -Be 'slap'
        }
        it 'bumps' {
            Read-Stuff | should -Be 'fist bump'
        }
    }
}