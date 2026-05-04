'use client'

export default function PatientsPanel() {
  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Patients</h1>
        <p className="text-gray-500 mt-1">Manage registered patients</p>
      </div>
      <div className="bg-white rounded-2xl p-12 shadow-sm border border-gray-100 text-center">
        <span className="text-6xl">🧑‍🤝‍🧑</span>
        <p className="text-gray-500 mt-4">Patient management panel</p>
        <p className="text-sm text-gray-400 mt-2">Requires Firestore database to be set up</p>
      </div>
    </div>
  )
}
