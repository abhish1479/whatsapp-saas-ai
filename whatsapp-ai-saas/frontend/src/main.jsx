
import React, {useState, useEffect} from 'react'
import { createRoot } from 'react-dom/client'

const API = (path)=> `${location.protocol}//${location.hostname}:8000${path}`

function App(){
  const [token,setToken]=useState(null)
  const [biz,setBiz]=useState({name:'',email:'',password:''})
  const [lead,setLead]=useState({name:'',phone:''})
  const [credits,setCredits]=useState(null)
  const [packs,setPacks]=useState([])
  const [order,setOrder]=useState(null)

  const signup = async()=>{
    const r = await fetch(API('/auth/signup'), {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({business_name:biz.name,email:biz.email,password:biz.password})})
    const j = await r.json(); if(j.token){ setToken(j.token)} else alert(JSON.stringify(j))
  }
  const login = async()=>{
    const r = await fetch(API('/auth/login'), {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({email:biz.email,password:biz.password})})
    const j = await r.json(); if(j.token){ setToken(j.token)} else alert(JSON.stringify(j))
  }
  const authed = (path, init={})=> fetch(API(path), { ...init, headers:{...(init.headers||{}), 'Authorization':'Bearer '+token}})

  const loadPacks = async()=>{
    const r = await authed('/billing/packs'); const j = await r.json(); setPacks(j)
  }
  const buyPack = async(id)=>{
    const r = await authed('/billing/create_order',{method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({pack_id:id})})
    const j = await r.json(); setOrder(j)
    alert('Order created. Use Razorpay Checkout with this order.id and key_id on your production site.')
  }
  const getCredits = async()=>{
    const r = await authed('/wallet'); const j = await r.json(); setCredits(j.credits)
  }
  const addLead = async()=>{
    await authed('/leads/add',{method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(lead)})
    alert('Lead saved!')
  }

  useEffect(()=>{ if(token){ getCredits(); loadPacks(); } },[token])

  return (
    <div className="card">
      <h2>LeadBot SaaS • Onboarding</h2>
      {!token ? (<>
        <p className="muted">Create your tenant & account</p>
        <input placeholder="Business Name" value={biz.name} onChange={e=>setBiz({...biz,name:e.target.value})}/>
        <input placeholder="Email" value={biz.email} onChange={e=>setBiz({...biz,email:e.target.value})}/>
        <input placeholder="Password" type="password" value={biz.password} onChange={e=>setBiz({...biz,password:e.target.value})}/>
        <div className="row">
          <button onClick={signup}>Sign up</button>
          <button onClick={login} style={{background:'#ef4444'}}>Login</button>
        </div>
        <div className="section">
          <span className="pill">Razorpay</span>
          <span className="pill">360dialog</span>
          <span className="pill">Chroma RAG</span>
        </div>
      </>) : (<>
        <p className="muted">Token acquired. Tenant ready.</p>
        <div className="row"><button onClick={getCredits}>Check Credits</button>{credits!==null && <b style={{marginLeft:8}}>Credits: {credits}</b>}</div>

        <h3 className="section">Buy Credits (Razorpay)</h3>
        <div className="row">
          {packs.map(p=>(
            <div key={p.id} style={{flex:'1 1 45%', border:'1px solid #eee', borderRadius:10, padding:12, margin:'6px 0', minWidth:200}}>
              <b>{p.label}</b>
              <div className="muted" style={{margin:'6px 0'}}>₹{(p.amount/100).toFixed(2)} • {p.credits} credits</div>
              <button onClick={()=>buyPack(p.id)}>Create Order</button>
            </div>
          ))}
        </div>

        <h3 className="section">Add a Lead</h3>
        <input placeholder="Lead Name" value={lead.name} onChange={e=>setLead({...lead,name:e.target.value})}/>
        <input placeholder="Lead Phone (E.164)" value={lead.phone} onChange={e=>setLead({...lead,phone:e.target.value})}/>
        <button onClick={addLead}>Add Lead</button>
      </>)}
    </div>
  )
}

createRoot(document.getElementById('root')).render(<App/>)
